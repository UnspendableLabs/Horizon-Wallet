import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:logger/logger.dart';

class ComposeDestroyBloc extends ComposeBaseBloc<ComposeDestroyState> {
  final Logger logger = Logger();

  ComposeDestroyBloc()
      : super(ComposeDestroyState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
        ));

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        submitState: const SubmitInitial()));
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    // try {
    //   final feeRate = _getFeeRate();
    //   final source = event.sourceAddress;
    //   final asset = event.params.asset;
    //   final giveQuantity = event.params.giveQuantity;
    //   final escrowQuantity = event.params.escrowQuantity;
    //   final mainchainrate = event.params.mainchainrate;

    //   final composeResponse = await composeTransactionUseCase.call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
    //       feeRate: feeRate,
    //       source: source,
    //       params: ComposeDispenserParams(
    //           source: source,
    //           asset: asset,
    //           giveQuantity: giveQuantity,
    //           escrowQuantity: escrowQuantity,
    //           mainchainrate: mainchainrate,
    //           status: 10),
    //       composeFn: composeRepository.composeDispenserVerbose);

    //   final composed = composeResponse.$1;
    //   final virtualSize = composeResponse.$2;

    //   emit(state.copyWith(
    //       submitState: SubmitComposingTransaction<ComposeDispenserResponseVerbose, void>(
    //     composeTransaction: composed,
    //     fee: composed.btcFee,
    //     feeRate: feeRate,
    //     virtualSize: virtualSize.virtualSize,
    //     adjustedVirtualSize: virtualSize.adjustedVirtualSize,
    //   )));
    // } on ComposeTransactionException catch (e) {
    //   emit(state.copyWith(submitState: SubmitInitial(loading: false, error: e.message)));
    // } catch (e) {
    //   emit(state.copyWith(
    //       submitState: SubmitInitial(loading: false, error: 'An unexpected error occurred: ${e.toString()}')));
    // }
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
    // emit(state.copyWith(
    //     submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
    //   loading: false,
    //   error: null,
    //   composeTransaction: event.composeTransaction,
    //   fee: event.fee,
    // )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    // if (state.submitState is! SubmitFinalizing<ComposeDispenserResponseVerbose>) {
    //   return;
    // }

    // final s = (state.submitState as SubmitFinalizing<ComposeDispenserResponseVerbose>);
    // final compose = s.composeTransaction;
    // final fee = s.fee;

    // emit(state.copyWith(
    //     submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
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

    //       logger.d('dispenser broadcasted txHash: $txHash');
    //       analyticsService.trackAnonymousEvent('broadcast_tx_dispenser_close', properties: {'distinct_id': uuid.v4()});

    //       emit(state.copyWith(submitState: SubmitSuccess(transactionHex: txHex, sourceAddress: compose.params.source)));
    //     },
    //     onError: (msg) {
    //       emit(state.copyWith(
    //           submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
    //         loading: false,
    //         error: msg,
    //         fee: fee,
    //         composeTransaction: compose,
    //       )));
    //     });
  }
}
