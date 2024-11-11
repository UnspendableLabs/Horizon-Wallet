import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

import "./compose_order_state.dart";
// import "./compose_order_event.dart";

class ComposeOrderEventParams {
  final String initialGiveAsset;
  final int initialGiveQuantity;
  final String initialGetAsset;
  final int initialGetQuantity;
  ComposeOrderEventParams({
    required this.initialGiveAsset,
    required this.initialGiveQuantity,
    required this.initialGetAsset,
    required this.initialGetQuantity,
  });
}

class ComposeOrderBloc extends ComposeBaseBloc<ComposeOrderState> {
  final Logger logger;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;

  ComposeOrderBloc({
    required this.logger,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.getFeeEstimatesUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
  }) : super(ComposeOrderState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
        ));

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    if (event.assetName == null || event.currentAddress == null) {
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
    ));

    late FeeEstimates feeEstimates;

    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        targets: (1, 3, 6),
      );
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.success([]),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final giveQuantity = event.params.giveQuantity;
      final giveAsset = event.params.giveAsset;
      final getQuantity = event.params.getQuantity;
      final getAsset = event.params.getAsset;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeOrderParams, ComposeOrderResponse>(
        source: source,
        feeRate: feeRate,
        params: ComposeOrderParams(
          source: source,
          giveQuantity: giveQuantity,
          giveAsset: giveAsset,
          getQuantity: getQuantity,
          getAsset: getAsset,
        ),
        composeFn: composeRepository.composeOrder,
      );

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<ComposeOrderResponse,
              ComposeOrderEventParams>(
        composeTransaction: composed,
        fee: composed.btcFee,
        feeRate: feeRate,
        virtualSize: virtualSize.virtualSize,
        adjustedVirtualSize: virtualSize.adjustedVirtualSize,
      )));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(loading: false, error: e.message)));
    } catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(
              loading: false,
              error: 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeOrderResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeOrderResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeOrderResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeOrderResponse>(
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

          analyticsService.trackEvent('broadcast_tx_order');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeOrderResponse>(
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
}
