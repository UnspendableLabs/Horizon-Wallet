import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/get_fee_option.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/forms/send_form/send_form_event.dart';

class SendData {}

class SendFormBloc extends Bloc<TransactionEvent,
    TransactionState<SendData, ComposeSendResponse>> {
  final TransactionType transactionType = TransactionType.send;
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final Logger logger;
  final HttpConfig httpConfig;

  SendFormBloc({
    required this.httpConfig,
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
  }) : super(TransactionState<SendData, ComposeSendResponse>(
          formState: TransactionFormState<SendData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<SendDependenciesRequested>(_onDependenciesRequested);
    on<SendTransactionComposed>(_onTransactionComposed);
    on<SendTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    SendDependenciesRequested event,
    Emitter<TransactionState<SendData, ComposeSendResponse>> emit,
  ) async {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dataState: const TransactionDataState.loading(),
      ),
    ));

    try {
      final balances = await balanceRepository.getBalancesForAddressesAndAsset(
          addresses: event.addresses,
          assetName: event.assetName,
          type: BalanceType.address,
          httpConfig: httpConfig);

      final feeEstimates =
          await getFeeEstimatesUseCase.call(httpConfig: httpConfig);

      emit(
        state.copyWith(
          formState: state.formState.copyWith(
            balancesState: BalancesState.success(balances),
            feeState: FeeState.success(feeEstimates),
            dataState: TransactionDataState.success(SendData()),
          ),
        ),
      );
    } catch (e) {
      logger.error('Error getting dependencies: $e');
      emit(
        state.copyWith(
          formState: state.formState.copyWith(
            balancesState: BalancesState.error(e.toString()),
            feeState: FeeState.error(e.toString()),
            dataState: TransactionDataState.error(e.toString()),
          ),
        ),
      );
    }
  }

  void _onTransactionComposed(
    SendTransactionComposed event,
    Emitter<TransactionState<SendData, ComposeSendResponse>> emit,
  ) async {
    emit(state.copyWith(composeState: const ComposeStateLoading()));
    if (event.sourceAddress.isEmpty) {
      emit(state.copyWith(
        composeState: const ComposeStateError('Source address is required'),
      ));
      return;
    }

    try {
      final feeRate = getFeeRate(state);
      final source = event.sourceAddress;
      final destination = event.destinationAddress;
      final asset = event.asset;
      final quantity = event.quantity;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeSendParams, ComposeSendResponse>(
        httpConfig: httpConfig,
        feeRate: feeRate,
        source: source,
        params: ComposeSendParams(
          source: source,
          destination: destination,
          asset: asset,
          quantity: quantity,
        ),
        composeFn: composeRepository.composeSendVerbose,
      );

      emit(state.copyWith(
        composeState: ComposeStateSuccess(composeResponse),
      ));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e is ComposeTransactionException
            ? e.message
            : 'An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  void _onTransactionBroadcasted(
    SendTransactionBroadcasted event,
    Emitter<TransactionState<SendData, ComposeSendResponse>> emit,
  ) async {
    try {
      emit(state.copyWith(broadcastState: const BroadcastState.loading()));

      final composeData = state.getComposeDataOrThrow();

      await signAndBroadcastTransactionUseCase.call(
          httpConfig: httpConfig,
          decryptionStrategy: event.decryptionStrategy,
          source: composeData.params.source,
          rawtransaction: composeData.rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(
              hex: txHex,
              hash: txHash,
              httpConfig: httpConfig,
            );

            logger.info('send broadcasted txHash: $txHash');
            analyticsService.trackAnonymousEvent(
                'broadcast_tx_${transactionType.name}',
                properties: {'distinct_id': uuid.v4()});

            emit(state.copyWith(
                broadcastState: BroadcastState.success(
                    BroadcastStateSuccess(txHex: txHex, txHash: txHash))));
          },
          onError: (msg) {
            emit(state.copyWith(broadcastState: BroadcastState.error(msg)));
          });
    } catch (e) {
      emit(state.copyWith(broadcastState: BroadcastState.error(e.toString())));
    }
  }

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<TransactionState<SendData, ComposeSendResponse>> emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
