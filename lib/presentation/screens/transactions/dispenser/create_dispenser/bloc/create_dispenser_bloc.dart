import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/get_fee_option.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/bloc/create_dispenser_event.dart';

class CreateDispenserData {
  final MultiAddressBalance btcBalances;
  final List<Dispenser>? openDispensers;
  CreateDispenserData({
    required this.btcBalances,
    this.openDispensers,
  });

  CreateDispenserData copyWith({
    MultiAddressBalance? btcBalances,
    List<Dispenser>? openDispensers,
  }) {
    return CreateDispenserData(
      btcBalances: btcBalances ?? this.btcBalances,
      openDispensers: openDispensers ?? this.openDispensers,
    );
  }
}

class CreateDispenserBloc extends Bloc<TransactionEvent,
    TransactionState<CreateDispenserData, ComposeDispenserResponseVerbose>> {
  final TransactionType transactionType = TransactionType.dispenser;
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writeLocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final Logger logger;
  final SettingsRepository settingsRepository;
  final DispenserRepository dispenserRepository;
  CreateDispenserBloc({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.dispenserRepository,
    required this.composeRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writeLocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
  }) : super(TransactionState<CreateDispenserData,
            ComposeDispenserResponseVerbose>(
          formState: TransactionFormState<CreateDispenserData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<CreateDispenserDependenciesRequested>(_onDependenciesRequested);
    on<CreateDispenserAddressSelected>(_onAddressSelected);
    on<CreateDispenserComposed>(_onTransactionComposed);
    on<CreateDispenserTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    CreateDispenserDependenciesRequested event,
    Emitter<
            TransactionState<CreateDispenserData,
                ComposeDispenserResponseVerbose>>
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
          event.addresses, event.assetName, BalanceType.address);

      final feeEstimates = await getFeeEstimatesUseCase.call();

      final List<String> balanceAddresses =
          balances.entries.map((entry) => entry.address!).toList();

      final btcBalances =
          await balanceRepository.getBtcBalancesForAddresses(balanceAddresses);

      emit(
        state.copyWith(
          formState: state.formState.copyWith(
            balancesState: BalancesState.success(balances),
            feeState: FeeState.success(feeEstimates),
            dataState: TransactionDataState.success(
                CreateDispenserData(btcBalances: btcBalances)),
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

  void _onAddressSelected(
    CreateDispenserAddressSelected event,
    Emitter<
            TransactionState<CreateDispenserData,
                ComposeDispenserResponseVerbose>>
        emit,
  ) async {
    final dispensers = await dispenserRepository
        .getDispensersByAddress(event.address)
        .run()
        .then((either) => either.fold(
              (error) => throw error, // Handle failure
              (dispensers) => dispensers, // Handle success
            ));

    // Get the current data from the TransactionDataState
    final currentData = state.formState.dataState.maybeWhen(
      success: (data) => data,
      orElse: () => throw StateError('No data available'),
    );

    // Create a new data object with updated dispensers using copyWith
    final updatedData = currentData.copyWith(openDispensers: dispensers);

    // Update the state with the new data
    emit(state.copyWith(
      formState: state.formState.copyWith(
        dataState: TransactionDataState.success(updatedData),
      ),
    ));
  }

  void _onTransactionComposed(
    CreateDispenserComposed event,
    Emitter<
            TransactionState<CreateDispenserData,
                ComposeDispenserResponseVerbose>>
        emit,
  ) async {
    emit(state.copyWith(composeState: const ComposeStateLoading()));

    try {
      final feeRate = getFeeRate(state);
      final source = event.sourceAddress;
      final asset = event.params.asset;
      final giveQuantity = event.params.giveQuantity;
      final escrowQuantity = event.params.escrowQuantity;
      final mainchainrate = event.params.mainchainrate;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: feeRate,
              source: source,
              params: ComposeDispenserParams(
                  source: source,
                  asset: asset,
                  giveQuantity: giveQuantity,
                  escrowQuantity: escrowQuantity,
                  mainchainrate: mainchainrate),
              composeFn: composeRepository.composeDispenserVerbose);

      emit(state.copyWith(
        composeState: ComposeStateSuccess(composeResponse),
      ));
    } catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.toString()),
      ));
    }
  }

  void _onTransactionBroadcasted(
    CreateDispenserTransactionBroadcasted event,
    Emitter<
            TransactionState<CreateDispenserData,
                ComposeDispenserResponseVerbose>>
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
            await writeLocalTransactionUseCase.call(txHex, txHash);

            logger.info('${transactionType.name} broadcasted txHash: $txHash');
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
    Emitter<
            TransactionState<CreateDispenserData,
                ComposeDispenserResponseVerbose>>
        emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
