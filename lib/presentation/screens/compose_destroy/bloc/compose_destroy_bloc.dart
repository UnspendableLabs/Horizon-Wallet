import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/http_config.dart';
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
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

class ComposeDestroyEventParams {
  final String assetName;
  final int quantity;
  final String tag;

  ComposeDestroyEventParams({
    required this.assetName,
    required this.quantity,
    required this.tag,
  });
}

class ComposeDestroyBloc extends ComposeBaseBloc<ComposeDestroyState> {
  final txName = 'destroy';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;
  final HttpConfig httpConfig;

  ComposeDestroyBloc({
    required this.httpConfig,
    required this.inMemoryKeyRepository,
    required this.passwordRequired,
    required this.balanceRepository,
    required this.composeRepository,
    required this.analyticsService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
  }) : super(
          ComposeDestroyState(
            submitState: const FormStep(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
          ),
          composePage: 'compose_destroy',
        );

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      submitState: const FormStep(),
    ));

    List<Balance> balances;
    FeeEstimates feeEstimates;

    try {
      balances = await balanceRepository.getBalancesForAddress(
          httpConfig: httpConfig,
          address: event.currentAddress!,
          excludeUtxoAttached: true);
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      return;
    }
    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        httpConfig: httpConfig,
      );
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      balancesState: BalancesState.success(
          balances.where((balance) => balance.asset != 'BTC').toList()),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFormSubmitted(FormSubmitted event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));
    final ComposeDestroyEventParams params = event.params;

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final asset = params.assetName;
      final quantity = params.quantity;
      final tag = params.tag;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeDestroyParams, ComposeDestroyResponse>(
              httpConfig: httpConfig,
              feeRate: feeRate,
              source: source,
              params: ComposeDestroyParams(
                  source: source, asset: asset, quantity: quantity, tag: tag),
              composeFn: composeRepository.composeDestroy);

      emit(state.copyWith(
          submitState: ReviewStep<ComposeDestroyResponse, void>(
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

  num _getFeeRate() {
    FeeEstimates feeEstimates = state.feeState.feeEstimatesOrThrow();
    return switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }

  @override
  void onReviewSubmitted(ReviewSubmitted event, emit) async {
    if (passwordRequired) {
      emit(state.copyWith(
          submitState: PasswordStep<ComposeDestroyResponse>(
        loading: false,
        error: null,
        composeTransaction: event.composeTransaction,
        fee: event.fee,
      )));
      return;
    }

    final s = (state.submitState as ReviewStep<ComposeDestroyResponse, void>);
    try {
      emit(state.copyWith(submitState: s.copyWith(loading: true)));

      await signAndBroadcastTransactionUseCase.call(
          httpConfig: httpConfig,
          decryptionStrategy: InMemoryKey(),
          source: s.composeTransaction.params.source,
          rawtransaction: s.composeTransaction.rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(
                hex: txHex, hash: txHash, httpConfig: httpConfig);

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
    if (state.submitState is! PasswordStep<ComposeDestroyResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeDestroyResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeDestroyResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        httpConfig: httpConfig,
        decryptionStrategy: Password(event.password),
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(
              hex: txHex, hash: txHash, httpConfig: httpConfig);

          logger.debug('$txName broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_$txName',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: PasswordStep<ComposeDestroyResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
