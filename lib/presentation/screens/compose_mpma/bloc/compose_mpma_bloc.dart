import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }) : super(ComposeMpmaState.initial()) {
    // Register event handlers for entry updates
    on<UpdateEntryDestination>(_onUpdateEntryDestination);
    on<UpdateEntryAsset>(_onUpdateEntryAsset);
    on<UpdateEntryQuantity>(_onUpdateEntryQuantity);
    on<ToggleEntrySendMax>(_onToggleEntrySendMax);
    on<AddNewEntry>(_onAddNewEntry);
    on<RemoveEntry>(_onRemoveEntry);
  }

  void _onUpdateEntryDestination(
      UpdateEntryDestination event, Emitter<ComposeMpmaState> emit) {
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
      UpdateEntryAsset event, Emitter<ComposeMpmaState> emit) {
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
      UpdateEntryQuantity event, Emitter<ComposeMpmaState> emit) {
    final updatedEntries = List<MpmaEntry>.from(state.entries);
    updatedEntries[event.entryIndex] =
        updatedEntries[event.entryIndex].copyWith(
      quantity: event.quantity,
      sendMax: false,
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  void _onToggleEntrySendMax(
      ToggleEntrySendMax event, Emitter<ComposeMpmaState> emit) async {
    // return early if fee estimates haven't loaded
    FeeEstimates? feeEstimates = state.feeState.maybeWhen(
      success: (value) => value,
      orElse: () => null,
    );
    if (feeEstimates == null) return;

    final updatedEntries = List<MpmaEntry>.from(state.entries);
    final entry = updatedEntries[event.entryIndex];

    updatedEntries[event.entryIndex] = entry.copyWith(
      sendMax: event.value,
    );

    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));

    if (!event.value) return;

    try {
      updatedEntries[event.entryIndex] =
          updatedEntries[event.entryIndex].copyWith();

      emit(state.copyWith(entries: updatedEntries));
    } catch (e) {
      updatedEntries[event.entryIndex] =
          updatedEntries[event.entryIndex].copyWith(
        sendMax: false,
      );

      emit(state.copyWith(
        entries: updatedEntries,
        composeSendError: "Insufficient funds",
      ));
    }
  }

  void _onAddNewEntry(AddNewEntry event, Emitter<ComposeMpmaState> emit) {
    final updatedEntries = List<MpmaEntry>.from(state.entries)
      ..add(MpmaEntry.initial());
    emit(state.copyWith(
      entries: updatedEntries,
      submitState: const SubmitInitial(),
    ));
  }

  void _onRemoveEntry(RemoveEntry event, Emitter<ComposeMpmaState> emit) {
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

    emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
        submitState: const SubmitInitial()));
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
        int quantity;
        if (balance.assetInfo.divisible) {
          quantity =
              (Decimal.parse(entries[i].quantity) * Decimal.fromInt(100000000))
                  .toBigInt()
                  .toInt();
        } else {
          quantity = Decimal.parse(entries[i].quantity).toBigInt().toInt();
        }
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

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
        submitState: SubmitComposingTransaction<ComposeMpmaSendResponse, void>(
          composeTransaction: composed,
          fee: composed.btcFee,
          feeRate: feeRate,
          virtualSize: virtualSize.virtualSize,
          adjustedVirtualSize: virtualSize.adjustedVirtualSize,
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
    // if (state.submitState is! SubmitFinalizing<ComposeMpmaSendResponse>) {
    //   return;
    // }

    // final s = (state.submitState as SubmitFinalizing<ComposeMpmaSendResponse>);
    // final compose = s.composeTransaction;
    // final fee = s.fee;

    // emit(state.copyWith(
    //     submitState: SubmitFinalizing<ComposeMpmaSendResponse>(
    //   loading: true,
    //   error: null,
    //   fee: fee,
    //   composeTransaction: compose,
    // )));

    // await signAndBroadcastTransactionUseCase.call(
    //     password: event.password,
    //     source: compose.params.source,
    //     rawtransaction: compose.rawtransaction,
    //     onSuccess: (txHex, txHash) async {
    //       await writelocalTransactionUseCase.call(txHex, txHash);

    //       logger.info('mpma broadcasted txHash: $txHash');
    //       analyticsService.trackAnonymousEvent('broadcast_tx_mpma', properties: {'distinct_id': uuid.v4()});

    //       emit(state.copyWith(submitState: SubmitSuccess(transactionHex: txHex, sourceAddress: compose.params.source)));
    //     },
    //     onError: (msg) {
    //       emit(state.copyWith(
    //           submitState: SubmitFinalizing<ComposeMpmaSendResponse>(
    //         loading: false,
    //         error: msg,
    //         fee: fee,
    //         composeTransaction: compose,
    //       )));
    //     });
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
}
