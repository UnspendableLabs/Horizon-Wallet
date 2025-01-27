import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_sweep.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_sweep/bloc/compose_sweep_state.dart';

class ComposeSweepEventParams {
  final String destination;
  final int flags;
  final String memo;

  ComposeSweepEventParams({
    required this.destination,
    required this.flags,
    required this.memo,
  });
}

class ComposeSweepBloc extends ComposeBaseBloc<ComposeSweepState> {
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final EstimateXcpFeeRepository estimateXcpFeeRepository;
  final Logger logger;

  ComposeSweepBloc({
    required this.composeRepository,
    required this.analyticsService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.estimateXcpFeeRepository,
    required this.logger,
  }) : super(
            ComposeSweepState(
              submitState: const SubmitInitial(),
              feeOption: FeeOption.Medium(),
              balancesState: const BalancesState.initial(),
              feeState: const FeeState.initial(),
              sweepXcpFeeState: const SweepXcpFeeState.initial(),
            ),
            composePage: 'compose_sweep');

  @override
  Future<void> onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      submitState: const SubmitInitial(),
      sweepXcpFeeState: const SweepXcpFeeState.loading(),
    ));

    FeeEstimates feeEstimates;

    try {
      feeEstimates = await getFeeEstimatesUseCase.call();
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    int sweepXcpFee;
    try {
      sweepXcpFee = await estimateXcpFeeRepository
          .estimateSweepXcpFees(event.currentAddress!);
    } catch (e) {
      emit(state.copyWith(
          sweepXcpFeeState: SweepXcpFeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.success([]),
      feeState: FeeState.success(feeEstimates),
      sweepXcpFeeState: SweepXcpFeeState.success(sweepXcpFee),
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
    final ComposeSweepEventParams params = event.params;

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final destination = params.destination;
      final flags = params.flags;
      final memo = params.memo;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeSweepParams, ComposeSweepResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeSweepParams(
                  source: source,
                  destination: destination,
                  flags: flags,
                  memo: memo),
              composeFn: composeRepository.composeSweep);

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<ComposeSweepResponse, void>(
        composeTransaction: composeResponse,
        fee: composeResponse.btcFee,
        feeRate: feeRate,
        virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
        adjustedVirtualSize:
            composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
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

  int _getFeeRate() {
    FeeEstimates feeEstimates = state.feeState.feeEstimatesOrThrow();
    return switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeSweepResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeSweepResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeSweepResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeSweepResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        decryptionStrategy: Password(event.password),
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.debug('sweep broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_sweep',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeSweepResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
