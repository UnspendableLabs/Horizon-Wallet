import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_state.dart';

/// Send transaction data to be stored in the TransactionState.success state

class SendBloc extends Bloc<TransactionEvent,
    TransactionState<SendState, ComposeSendResponse>> {
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final Logger logger;
  final SettingsRepository settingsRepository;

  SendBloc({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
  }) : super(TransactionState<SendState, ComposeSendResponse>(
          feeOption: fee_option.Medium(),
          dataState: const TransactionDataState.initial(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
        )) {
    on<SendDependenciesRequested>(_onDependenciesRequested);
    on<SendTransactionComposed>(_onTransactionComposed);
    on<SendTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    SendDependenciesRequested event,
    Emitter<TransactionState<SendState, ComposeSendResponse>> emit,
  ) async {
    // First, emit loading state
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      dataState: const TransactionDataState.loading(),
    ));

    try {
      // Fetch the balances
      final balances = await balanceRepository.getBalancesForAddressesAndAsset(
          event.addresses, event.assetName, BalanceType.address);

      final feeEstimates = await getFeeEstimatesUseCase.call();

      // Emit success state with balances
      emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dataState: TransactionDataState.success(SendState())));
      print(state.toString());
    } catch (e) {
      // Emit error state with error message
      emit(state.copyWith(
          balancesState: BalancesState.error(e.toString()),
          feeState: FeeState.error(e.toString())));
    }

    print('SendDependenciesRequested');
  }

  void _onTransactionComposed(
    SendTransactionComposed event,
    Emitter<TransactionState<SendState, ComposeSendResponse>> emit,
  ) async {
    print('SendTransactionComposed');

    // First, emit loading state for the compose operation
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
      print(state.toString());
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
    Emitter<TransactionState<SendState, ComposeSendResponse>> emit,
  ) async {
    print('SendTransactionBroadcasted');

    try {
      final requirePassword =
          settingsRepository.requirePasswordForCryptoOperations;

      // emit(state.copyWith(submitState: s.copyWith(loading: true)));

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy:
              requirePassword ? Password(event.password!) : InMemoryKey(),
          source: state.getComposeDataOrThrow().params.source,
          rawtransaction: state.getComposeDataOrThrow().rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(txHex, txHash);

            logger.info('send broadcasted txHash: $txHash');
            analyticsService.trackAnonymousEvent('broadcast_tx_send',
                properties: {'distinct_id': uuid.v4()});
          },
          onError: (msg) {
            print('send broadcast error: $msg');
          });
    } catch (e) {
      print('send broadcast error: $e');
    }
  }

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<TransactionState<SendState, ComposeSendResponse>> emit,
  ) {
    // Update the fee option in the state
    emit(state.copyWith(
      feeOption: event.feeOption,
    ));
    print(state.toString());
  }
}
