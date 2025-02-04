import 'package:horizon/common/uuid.dart';
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
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

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
  final txName = 'fairminter';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final FetchFairminterFormDataUseCase fetchFairminterFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final BlockRepository blockRepository;

  ComposeFairminterBloc({
    required this.passwordRequired,
    required this.inMemoryKeyRepository,
    required this.logger,
    required this.fetchFairminterFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.blockRepository,
  }) : super(
          ComposeFairminterState(
            submitState: const FormStep(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            assetState: const AssetState.initial(),
            fairmintersState: const FairmintersState.initial(),
          ),
          composePage: 'compose_fairminter',
        );

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        assetState: const AssetState.loading(),
        submitState: const FormStep(),
        fairmintersState: const FairmintersState.loading()));

    try {
      final (assets, feeEstimates, fairminters) =
          await fetchFairminterFormDataUseCase.call(event.currentAddress!);

      // fairminters can be opened on any owned asset
      // however, we need to check the current fairminters and filter out owned assets if the asset is already minted

      // we can compose a new fairminter on an asset that had previously been minted if the fairminter is closed and not locked
      // grab the list of fairminters on which new fairminters cannot be composed
      final invalidFairminters = fairminters
          .where((fairminter) =>
              fairminter.status != 'closed' ||
              (fairminter.status == 'closed' &&
                  fairminter.lockQuantity == true))
          .toList();

      // get the list of assets that are already minted
      final invalidFairminterAssets = invalidFairminters
          .map((fairminter) {
            if (fairminter.asset != null) return fairminter.asset!;

            // some invalid fairminter statuses have this format: `invalid: Hard cap of asset `INVALID.ASSET` is already reached.`
            // we need to extract the invalid asset from this string
            final match =
                RegExp(r'`(.*?)`').firstMatch(fairminter.status ?? '');
            return match?.group(1) ?? '';
          })
          .where((asset) => asset.isNotEmpty)
          .toList();

      // filter out assets that have invalid fairminters
      final validAssets = assets
          .where((asset) =>
              !invalidFairminterAssets.contains(asset.asset) &&
              !invalidFairminterAssets.contains(asset.assetLongname))
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
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
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
  void onFormSubmitted(FormSubmitted event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));

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

      emit(state.copyWith(
          submitState: ReviewStep<ComposeFairminterResponse, void>(
        composeTransaction: composeResponse,
        fee: composeResponse.btcFee,
        feeRate: feeRate,
        virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
        adjustedVirtualSize:
            composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
      )));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
          submitState: FormStep(loading: false, error: e.message)));
    } catch (e) {
      emit(state.copyWith(
          submitState: FormStep(
              loading: false,
              error: 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onReviewSubmitted(ReviewSubmitted event, emit) async {
    if (passwordRequired) {
      emit(state.copyWith(
          submitState: PasswordStep<ComposeFairminterResponse>(
        loading: false,
        error: null,
        composeTransaction: event.composeTransaction,
        fee: event.fee,
      )));
      return;
    }

    final s =
        (state.submitState as ReviewStep<ComposeFairminterResponse, void>);

    try {
      emit(state.copyWith(submitState: s.copyWith(loading: true)));

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: InMemoryKey(),
          source: s.composeTransaction.params.source,
          rawtransaction: s.composeTransaction.rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(txHex, txHash);

            logger.info('$txName broadcasted txHash: $txHash');
            analyticsService.trackAnonymousEvent('broadcast_tx_$txName',
                properties: {'distinct_id': uuid.v4()});

            emit(state.copyWith(
                submitState: SubmitSuccess(
                    transactionHex: txHex,
                    sourceAddress: s.composeTransaction.params.source)));
          },
          onError: (msg) {
            emit(state.copyWith(
                submitState:
                    s.copyWith(loading: false, error: msg.toString())));
          });
    } catch (e) {
      emit(state.copyWith(
          submitState: s.copyWith(loading: false, error: e.toString())));
    }
  }

  @override
  void onSignAndBroadcastFormSubmitted(
      SignAndBroadcastFormSubmitted event, emit) async {
    if (state.submitState is! PasswordStep<ComposeFairminterResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeFairminterResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeFairminterResponse>(
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

          logger.info('$txName broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_$txName',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: PasswordStep<ComposeFairminterResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
