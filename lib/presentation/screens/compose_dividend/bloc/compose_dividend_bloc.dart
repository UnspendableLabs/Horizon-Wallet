import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_state.dart';
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';

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
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final FetchDividendFormDataUseCase fetchDividendFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;

  ComposeDividendBloc({
    required this.composeRepository,
    required this.analyticsService,
    required this.fetchDividendFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
  }) : super(
          ComposeDividendState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            assetState: const AssetState.initial(),
            dividendXcpFeeState: const DividendXcpFeeState.initial(),
          ),
          composePage: 'compose_dividend',
        );

  @override
  Future<void> onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        submitState: const SubmitInitial(),
        assetState: const AssetState.loading(),
        dividendXcpFeeState: const DividendXcpFeeState.loading()));

    int dividendXcpFee;
    List<Balance> balances;
    Asset asset;
    FeeEstimates feeEstimates;

    try {
      (balances, asset, feeEstimates, dividendXcpFee) =
          await fetchDividendFormDataUseCase.call(
              event.currentAddress!, event.assetName!);

      emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
        assetState: AssetState.success(asset),
        dividendXcpFeeState: DividendXcpFeeState.success(dividendXcpFee),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } on FetchAssetException catch (e) {
      emit(state.copyWith(
        assetState: AssetState.error(e.message),
      ));
    } on FetchBalancesException catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.message),
      ));
    } on FetchDividendXcpFeeException catch (e) {
      emit(state.copyWith(
        dividendXcpFeeState: DividendXcpFeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
        assetState:
            AssetState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));
    final params = event.params as ComposeDividendEventParams;

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

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeDividendResponse, void>(
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
