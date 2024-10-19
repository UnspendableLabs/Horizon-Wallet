import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
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
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_state.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';

class ComposeFairmintEventParams {
  final String asset;

  ComposeFairmintEventParams({
    required this.asset,
  });
}

class ComposeFairmintBloc extends ComposeBaseBloc<ComposeFairmintState> {
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final FetchComposeFairmintFormDataUseCase fetchComposeFairmintFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final BlockRepository blockRepository;

  ComposeFairmintBloc({
    required this.logger,
    required this.fetchComposeFairmintFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.blockRepository,
  }) : super(ComposeFairmintState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          fairmintersState: const FairmintersState.initial(),
        ));

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        fairmintersState: const FairmintersState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (feeEstimates, fairminters) =
          await fetchComposeFairmintFormDataUseCase.call();
      // final block = await blockRepository.getLastBlock();

      final validFairminters = fairminters.where((fairminter) {
        return fairminter.status != null &&
            fairminter.status == 'open' &&
            fairminter.price != null &&
            fairminter.price! == 0;
      }).toList();

      emit(state.copyWith(
        balancesState: const BalancesState.success([]),
        feeState: FeeState.success(feeEstimates),
        fairmintersState: FairmintersState.success(validFairminters),
      ));
    } on FetchFairmintersException catch (e) {
      emit(state.copyWith(
        fairmintersState: FairmintersState.error(e.message),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        fairmintersState: FairmintersState.error(
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

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final asset = event.params.asset;

      final composed = await composeTransactionUseCase
          .call<ComposeFairmintParams, ComposeFairmintResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeFairmintParams(source: source, asset: asset),
              composeFn: composeRepository.composeFairmintVerbose);

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeFairmintResponse, void>(
        composeTransaction: composed,
        fee: composed.btcFee,
        feeRate: feeRate,
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
        submitState: SubmitFinalizing<ComposeFairmintResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeFairmintResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeFairmintResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeFairmintResponse>(
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

          logger.info('fairmint broadcasted txHash: $txHash');
          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));

          analyticsService.trackEvent('broadcast_tx_dispenser_close');
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeFairmintResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}