import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
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
import 'package:horizon/presentation/screens/transactions/lock_quantity/bloc/lock_quantity_event.dart';
import 'package:horizon/domain/entities/http_clients.dart';

class LockQuantityData {
  final MultiAddressBalanceEntry ownerBalanceEntry;
  LockQuantityData({
    required this.ownerBalanceEntry,
  });
}

class LockQuantityBloc extends Bloc<TransactionEvent,
    TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>> {
  final TransactionType transactionType = TransactionType.lockQuantity;
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final Logger logger;
  final HttpClients httpClients;

  LockQuantityBloc({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
    required this.httpClients,
  }) : super(TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>(
          formState: TransactionFormState<LockQuantityData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<LockQuantityDependenciesRequested>(_onDependenciesRequested);
    on<LockQuantityTransactionComposed>(_onTransactionComposed);
    on<LockQuantityTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    LockQuantityDependenciesRequested event,
    Emitter<TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>>
        emit,
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
          client: httpClients.counterparty,
          addresses: event.addresses,
          assetName: event.assetName,
          type: BalanceType.address);

      final feeEstimates = await getFeeEstimatesUseCase.call();

      final ownerAddress = balances.assetInfo.owner;
      if (!event.addresses.contains(ownerAddress)) {
        emit(state.copyWith(
          formState: state.formState.copyWith(
            balancesState:
                const BalancesState.error('invariant: owner address not found'),
          ),
        ));
        return;
      }

      final ownerBalanceEntries = balances.entries
          .where((entry) => (entry.address == ownerAddress))
          .toList();

      if (ownerBalanceEntries.isEmpty) {
        // we should never get here because issuance actions are only exposed to the owner addresses
        emit(state.copyWith(
          formState: state.formState.copyWith(
            balancesState: const BalancesState.error('No owner balance found'),
          ),
        ));
      } else if (ownerBalanceEntries.length > 1) {
        // we should never get here because assets can only have one address owner
        emit(state.copyWith(
          formState: state.formState.copyWith(
            balancesState:
                const BalancesState.error('Multiple owner balances found'),
          ),
        ));
      } else {
        emit(
          state.copyWith(
            formState: state.formState.copyWith(
              balancesState: BalancesState.success(balances),
              feeState: FeeState.success(feeEstimates),
              dataState: TransactionDataState.success(LockQuantityData(
                ownerBalanceEntry: ownerBalanceEntries.first,
              )),
            ),
          ),
        );
      }
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
    LockQuantityTransactionComposed event,
    Emitter<TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>>
        emit,
  ) async {
    emit(state.copyWith(composeState: const ComposeStateLoading()));

    try {
      final feeRate = getFeeRate(state);

      final composeResponse = await composeTransactionUseCase
          .call<ComposeIssuanceParams, ComposeIssuanceResponseVerbose>(
        feeRate: feeRate,
        source: event.sourceAddress,
        params: ComposeIssuanceParams(
          source: event.sourceAddress,
          name: event.params.name,
          quantity: event.params.quantity,
          divisible: event.params.divisible,
          lock: event.params.lock,
          reset: event.params.reset,
          description: event.params.description,
        ),
        composeFn: composeRepository.composeIssuanceVerbose,
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
    LockQuantityTransactionBroadcasted event,
    Emitter<TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>>
        emit,
  ) async {
    try {
      emit(state.copyWith(broadcastState: const BroadcastState.loading()));

      final composeData = state.getComposeDataOrThrow();

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: event.decryptionStrategy,
          source: composeData.params.source,
          rawtransaction: composeData.rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(txHex, txHash);

            logger.info('lock quantity broadcasted txHash: $txHash');
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
    Emitter<TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>>
        emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
