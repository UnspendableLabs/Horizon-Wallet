import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_event.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_state.dart';

class ComposeMpmaEventParams {}

class ComposeMpmaBloc extends ComposeBaseBloc<ComposeMpmaState> {
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final TransactionService transactionService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;

  ComposeMpmaBloc({
    required this.balanceRepository,
    required this.composeRepository,
    required this.analyticsService,
    required this.transactionService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
  }) : super(
          ComposeMpmaState.initial(),
          composePage: 'compose_mpma',
        ) {
    // Register event handlers for entry updates
    on<EntryDestinationUpdated>(_onUpdateEntryDestination);
    on<EntryAssetUpdated>(_onUpdateEntryAsset);
    on<EntryQuantityUpdated>(_onUpdateEntryQuantity);
    on<EntrySendMaxToggled>(_onToggleEntrySendMax);
    on<NewEntryAdded>(_onAddNewEntry);
    on<EntryRemoved>(_onRemoveEntry);
  }

  void _onUpdateEntryDestination(
      EntryDestinationUpdated event, Emitter<ComposeMpmaState> emit) {
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    updatedEntries[event.entryIndex] =
        updatedEntries[event.entryIndex].copyWith(
      destination: event.destination,
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  void _onUpdateEntryAsset(
      EntryAssetUpdated event, Emitter<ComposeMpmaState> emit) {
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    updatedEntries[event.entryIndex] =
        updatedEntries[event.entryIndex].copyWith(
      asset: event.asset,
      sendMax: false,
      quantity: '',
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  void _onUpdateEntryQuantity(
      EntryQuantityUpdated event, Emitter<ComposeMpmaState> emit) {
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    final entry = updatedEntries[event.entryIndex];

    if (entry.asset != null && event.quantity.isNotEmpty) {
      try {
        final inputQuantity = Decimal.parse(event.quantity);
        final remainingBalance = getRemainingBalanceForAsset(
          entry.asset!,
          event.entryIndex,
        );

        // Validate that input doesn't exceed remaining balance
        if (inputQuantity > remainingBalance) {
          emit(state.copyWith(
            composeSendError: "Quantity exceeds available balance",
          ));
          return;
        }
      } catch (_) {
        // Handle invalid number format
      }
    }

    updatedEntries[event.entryIndex] = entry.copyWith(
      quantity: event.quantity,
      sendMax: false,
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
      composeSendError: null,
    ));
  }

  void _onToggleEntrySendMax(
      EntrySendMaxToggled event, Emitter<ComposeMpmaState> emit) async {
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    final entry = updatedEntries[event.entryIndex];

    if (!event.value || entry.asset == null) {
      updatedEntries[event.entryIndex] = entry.copyWith(sendMax: event.value);
      emit(state.copyWith(entries: updatedEntries));
      return;
    }

    final remainingBalance = getRemainingBalanceForAsset(
      entry.asset!,
      event.entryIndex,
    );

    updatedEntries[event.entryIndex] = entry.copyWith(
      sendMax: event.value,
      quantity: remainingBalance.toString(),
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
      composeSendError: null,
    ));
  }

  void _onAddNewEntry(NewEntryAdded event, Emitter<ComposeMpmaState> emit) {
    // Get the first available non-BTC asset from balances
    final firstAsset = state.balancesState.maybeWhen(
      success: (balances) => balances.isNotEmpty ? balances[0].asset : null,
      orElse: () => null,
    );

    // Create a completely fresh entry using the initial factory
    final newEntry = MpmaEntry.initial().copyWith(
      asset: firstAsset,
      destination: null, // Explicitly set to null to ensure clean state
      quantity: '', // Ensure empty quantity
      sendMax: false, // Ensure sendMax is false
    );

    final updatedEntries = List<MpmaEntry>.from(state.entries)..add(newEntry);

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  void _onRemoveEntry(EntryRemoved event, Emitter<ComposeMpmaState> emit) {
    if (event.entryIndex <= 0 || event.entryIndex >= state.entries.length) {
      return;
    }

    final updatedEntries = List<MpmaEntry>.from(state.entries);
    updatedEntries.removeAt(event.entryIndex);

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  @override
  onChangeFeeOption(event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  onFetchFormData(event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
    ));

    late List<Balance> balances;
    late FeeEstimates feeEstimates;
    try {
      List<String> addresses = [event.currentAddress!];
      balances =
          await balanceRepository.getBalancesForAddress(addresses[0], true);
    } catch (e) {
      emit(state.copyWith(
          balancesState: BalancesState.error(e.toString()),
          submitState: const SubmitInitial()));
      return;
    }
    try {
      feeEstimates = await getFeeEstimatesUseCase.call();
    } catch (e) {
      emit(state.copyWith(
          feeState: FeeState.error(e.toString()),
          submitState: const SubmitInitial()));
      return;
    }

    final nonBtcBalances =
        balances.where((balance) => balance.asset != 'BTC').toList();

    // Set initial asset for the first entry if balances exist
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    if (nonBtcBalances.isNotEmpty) {
      updatedEntries[0] = updatedEntries[0].copyWith(
        asset: nonBtcBalances[0].asset,
      );
    }

    emit(state.copyWith(
      entries: updatedEntries,
      balancesState: BalancesState.success(nonBtcBalances),
      feeState: FeeState.success(feeEstimates),
      submitState: const SubmitInitial(),
    ));
  }

  @override
  onFinalizeTransaction(event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeMpmaSendResponse>(
            loading: false,
            error: null,
            composeTransaction: event.composeTransaction,
            fee: event.fee)));
  }

  @override
  onComposeTransaction(event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final source = event.sourceAddress;
      final feeRate = _getFeeRate();
      final entries = (state).entries;

      // Validate all entries are complete
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.destination == null || entry.destination!.isEmpty) {
          throw ComposeTransactionException(
              'Destination address is required for entry ${i + 1}');
        }
        if (entry.asset == null || entry.asset!.isEmpty) {
          throw ComposeTransactionException(
              'Asset is required for entry ${i + 1}');
        }
        if (entry.quantity.isEmpty) {
          throw ComposeTransactionException(
              'Quantity is required for entry ${i + 1}');
        }
      }

      // Create parallel arrays ensuring index alignment
      final destinations = List<String>.filled(entries.length, '');
      final assets = List<String>.filled(entries.length, '');
      final quantities = List<int>.filled(entries.length, 0);

      final balances = (state).balancesState.maybeWhen(
            success: (value) => value,
            orElse: () => null,
          );

      // Fill arrays maintaining index correlation
      for (var i = 0; i < entries.length; i++) {
        destinations[i] = entries[i].destination!;
        assets[i] = entries[i].asset!;
        final balance = balances
            ?.firstWhere((element) => element.asset == entries[i].asset);
        if (balance == null) {
          throw ComposeTransactionException(
              'Balance not found for asset ${entries[i].asset}');
        }
        int quantity = getQuantityForDivisibility(
            divisible: balance.assetInfo.divisible,
            inputQuantity: entries[i].quantity);
        quantities[i] = quantity;
      }

      final composeResponse = await composeTransactionUseCase
          .call<ComposeMpmaSendParams, ComposeMpmaSendResponse>(
        feeRate: feeRate,
        source: source,
        params: ComposeMpmaSendParams(
          source: source,
          destinations: destinations.join(','),
          assets: assets.join(','),
          quantities: quantities.join(','),
        ),
        composeFn: composeRepository.composeMpmaSend,
      );

      emit(state.copyWith(
        submitState: SubmitComposingTransaction<ComposeMpmaSendResponse, void>(
          composeTransaction: composeResponse,
          fee: composeResponse.btcFee,
          feeRate: feeRate,
          virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
          adjustedVirtualSize:
              composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
        ),
      ));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(loading: false, error: e.message)));
    } catch (e) {
      emit(state.copyWith(
        submitState: SubmitInitial(
          loading: false,
          error: e is ComposeTransactionException
              ? e.message
              : 'An unexpected error occurred: ${e.toString()}',
        ),
      ));
    }
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeMpmaSendResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeMpmaSendResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeMpmaSendResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        password: event.password,
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.info('mpma broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_mpma',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeMpmaSendResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }

  int _getFeeRate() {
    FeeEstimates feeEstimates = state.feeState.feeEstimatesOrThrow();
    return switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }

  Decimal getRemainingBalanceForAsset(String asset, int currentEntryIndex) {
    final balances = state.balancesState.maybeWhen(
      success: (balances) => balances,
      orElse: () => <Balance>[],
    );

    final balance = balances.firstWhereOrNull((b) => b.asset == asset);
    if (balance == null) return Decimal.zero;

    var totalUsed = Decimal.zero;

    // Sum up quantities used in previous entries for this asset
    for (var i = 0; i < state.entries.length; i++) {
      if (i == currentEntryIndex) continue; // Skip current entry

      final entry = state.entries[i];
      if (entry.asset == asset && entry.quantity.isNotEmpty) {
        try {
          totalUsed += Decimal.parse(entry.quantity);
        } catch (_) {
          // Handle invalid number format
        }
      }
    }

    // Calculate remaining balance
    final totalBalance = Decimal.parse(balance.quantityNormalized);
    final remaining = totalBalance - totalUsed;
    return remaining > Decimal.zero ? remaining : Decimal.zero;
  }
}
