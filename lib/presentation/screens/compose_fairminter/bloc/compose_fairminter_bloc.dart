import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
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
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_state.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';

class ComposeFairminterEventParams {
  final String asset;
  final int maxMintPerTx;
  final int hardCap;
  final bool divisible;
  final int? startBlock;
  final bool isLocked;
  final String? parent;
  final int? endBlock;
  ComposeFairminterEventParams({
    required this.asset,
    required this.maxMintPerTx,
    required this.hardCap,
    required this.divisible,
    this.startBlock,
    this.endBlock,
    required this.isLocked,
    this.parent,
  });
}

class ComposeFairminterBloc extends ComposeBaseBloc<ComposeFairminterState> {
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final FetchFairminterFormDataUseCase fetchFairminterFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final BlockRepository blockRepository;

  ComposeFairminterBloc({
    required this.logger,
    required this.fetchFairminterFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.blockRepository,
  }) : super(ComposeFairminterState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          assetState: const AssetState.initial(),
          fairmintersState: const FairmintersState.initial(),
        ));

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        assetState: const AssetState.loading(),
        submitState: const SubmitInitial(),
        fairmintersState: const FairmintersState.loading()));

    try {
      final (assets, feeEstimates, fairminters) =
          await fetchFairminterFormDataUseCase.call(event.currentAddress!);

      final fairminterAssets =
          fairminters.map((fairminter) => fairminter.asset).toList();
      final validAssets = assets
          .where((asset) => !fairminterAssets.contains(asset.asset))
          .toList();

      emit(state.copyWith(
        balancesState: const BalancesState.success([]),
        feeState: FeeState.success(feeEstimates),
        assetState: AssetState.success(validAssets),
        fairmintersState: FairmintersState.success(fairminters),
      ));
    } on FetchAssetsException catch (e) {
      emit(state.copyWith(
        assetState: AssetState.error(e.message),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } on FetchFairmintersException catch (e) {
      emit(state.copyWith(
        fairmintersState: FairmintersState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        assetState:
            AssetState.error('An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
        fairmintersState: FairmintersState.error(
            'An unexpected error occurred: ${e.toString()}'),
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

      final composeResponse = await composeTransactionUseCase
          .call<ComposeFairminterParams, ComposeFairminterResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeFairminterParams(
                  source: source,
                  assetParent: event.params.parent,
                  asset: event.params.asset,
                  maxMintPerTx: event.params.maxMintPerTx,
                  hardCap: event.params.hardCap,
                  startBlock: event.params.startBlock,
                  divisible: event.params.divisible,
                  lockQuantity: event.params.isLocked,
                  endBlock: event.params.endBlock),
              composeFn: composeRepository.composeFairminterVerbose);

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeFairminterResponse, void>(
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
        submitState: SubmitFinalizing<ComposeFairminterResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeFairminterResponse>) {
      return;
    }

    final s =
        (state.submitState as SubmitFinalizing<ComposeFairminterResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeFairminterResponse>(
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

          logger.info('fairminter broadcasted txHash: $txHash');
          analyticsService.trackEvent('broadcast_tx_fairminter');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeFairminterResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
