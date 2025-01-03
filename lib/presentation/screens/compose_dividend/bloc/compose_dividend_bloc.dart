import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_state.dart';

class ComposeDividendEventParams {
  final String assetName;
  final int quantityPerUnit;
  final String dividendAsset;

  ComposeDividendEventParams({
    required this.assetName,
    required this.quantityPerUnit,
    required this.dividendAsset,
  });
}

class ComposeDividendBloc extends ComposeBaseBloc<ComposeDividendState> {
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;

  ComposeDividendBloc({
    required this.balanceRepository,
    required this.composeRepository,
    required this.analyticsService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
  }) : super(ComposeDividendState(
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
      submitState: const SubmitInitial(),
    ));

    List<Balance> balances;
    FeeEstimates feeEstimates;

    try {
      // balances = await balanceRepository.getBalancesForAddressAndAssetVerbose(event.currentAddress!, event.assetName!);
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      return;
    }

    try {
      feeEstimates = await getFeeEstimatesUseCase.call();
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    // final balance = balances.where((balance) => balance.utxo == null).first;
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
    final ComposeDividendEventParams params = event.params;

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final asset = params.assetName;
      final quantityPerUnit = params.quantityPerUnit;
      final dividendAsset = params.dividendAsset;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeDividendParams, ComposeDividendResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeDividendParams(
                  source: source,
                  asset: asset,
                  quantityPerUnit: quantityPerUnit,
                  dividendAsset: dividendAsset),
              composeFn: composeRepository.composeDividend);

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeDividendResponse, void>(
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
        submitState: SubmitFinalizing<ComposeDividendResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeDividendResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeDividendResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDividendResponse>(
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

          logger.debug('dividend broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_dividend',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeDividendResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
