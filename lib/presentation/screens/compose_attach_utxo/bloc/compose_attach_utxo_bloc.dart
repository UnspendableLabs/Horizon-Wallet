import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_state.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';

class ComposeAttachUtxoEventParams {
  final Asset asset;
  final int quantity;

  ComposeAttachUtxoEventParams({
    required this.asset,
    required this.quantity,
  });
}

class ComposeAttachUtxoBloc extends ComposeBaseBloc<ComposeAttachUtxoState> {
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final FetchComposeAttachUtxoFormDataUseCase
      fetchComposeAttachUtxoFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final BlockRepository blockRepository;
  final String? initialFairminterTxHash;

  ComposeAttachUtxoBloc({
    required this.logger,
    required this.fetchComposeAttachUtxoFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.blockRepository,
    this.initialFairminterTxHash,
  }) : super(ComposeAttachUtxoState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          assetState: const AssetState.initial(),
        ));

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    print('onFetchFormData');
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        submitState: const SubmitInitial(),
        assetState: const AssetState.loading()));

    print('fetching form data');
    try {
      print('fetching form data??????');
      final (feeEstimates, asset) =
          await fetchComposeAttachUtxoFormDataUseCase.call(event.assetName!);
      print('fetched form data');

      emit(state.copyWith(
        balancesState: const BalancesState.success([]),
        feeState: FeeState.success(feeEstimates),
        assetState: AssetState.success(asset),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
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
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    // try {
    //   final feeRate = _getFeeRate();
    //   final source = event.sourceAddress;
    //   final asset = event.params.asset;
    //   final quantity = event.params.quantity;

    //   final composeResponse = await composeTransactionUseCase.call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
    //       feeRate: feeRate,
    //       source: source,
    //       params: ComposeAttachUtxoParams(address: source, quantity: quantity, asset: asset),
    //       composeFn: composeRepository.composeAttachUtxoVerbose);

    //   final composed = composeResponse.$1;
    //   final virtualSize = composeResponse.$2;

    //   emit(state.copyWith(
    //       submitState: SubmitComposingTransaction<ComposeFairmintResponse, void>(
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

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    // emit(state.copyWith(
    //     submitState: SubmitFinalizing<ComposeFairmintResponse>(
    //   loading: false,
    //   error: null,
    //   composeTransaction: event.composeTransaction,
    //   fee: event.fee,
    // )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeAttachUtxoResponse>) {
      return;
    }

    // final s = (state.submitState as SubmitFinalizing<ComposeFairmintResponse>);
    // final compose = s.composeTransaction;
    // final fee = s.fee;

    // emit(state.copyWith(
    //     submitState: SubmitFinalizing<ComposeFairmintResponse>(
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

    //       logger.info('fairmint broadcasted txHash: $txHash');
    //       analyticsService.trackAnonymousEvent('broadcast_tx_fairmint', properties: {'distinct_id': uuid.v4()});

    //       emit(state.copyWith(submitState: SubmitSuccess(transactionHex: txHex, sourceAddress: compose.params.source)));
    //     },
    //     onError: (msg) {
    //       emit(state.copyWith(
    //           submitState: SubmitFinalizing<ComposeFairmintResponse>(
    //         loading: false,
    //         error: msg,
    //         fee: fee,
    //         composeTransaction: compose,
    //       )));
    //     });
  }
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
