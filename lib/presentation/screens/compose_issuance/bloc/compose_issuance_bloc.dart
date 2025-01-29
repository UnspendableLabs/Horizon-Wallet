import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_issuance/usecase/fetch_form_data.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class ComposeIssuanceEventParams {
  final String name;
  final int quantity;
  final String description;
  final bool divisible;
  final bool lock;
  final bool reset;

  ComposeIssuanceEventParams({
    required this.name,
    required this.quantity,
    required this.description,
    required this.divisible,
    required this.lock,
    required this.reset,
  });
}

class ComposeIssuanceBloc extends ComposeBaseBloc<ComposeIssuanceState> {
  final txName = 'issuance';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final TransactionService transactionService;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;
  final FetchIssuanceFormDataUseCase fetchIssuanceFormDataUseCase;

  ComposeIssuanceBloc({
    required this.passwordRequired,
    required this.balanceRepository,
    required this.composeRepository,
    required this.transactionService,
    required this.analyticsService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
    required this.fetchIssuanceFormDataUseCase,
    required this.inMemoryKeyRepository,
  }) : super(
          ComposeIssuanceState(
              submitState: const FormStep(),
              feeOption: FeeOption.Medium(),
              balancesState: const BalancesState.initial(),
              feeState: const FeeState.initial(),
              quantity: ''),
          composePage: 'compose_issuance',
        ) {
    // Event handlers specific to issuance
  }

  @override
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      submitState: const FormStep(),
    ));

    try {
      final (balances, feeEstimates) =
          await fetchIssuanceFormDataUseCase.call(event.currentAddress!);

      emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
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
  void onFormSubmitted(FormSubmitted event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeIssuanceParams, ComposeIssuanceResponseVerbose>(
        source: source,
        feeRate: feeRate,
        params: ComposeIssuanceParams(
          source: event.sourceAddress,
          name: event.params.name,
          quantity: event.params.quantity,
          description: event.params.description,
          divisible: event.params.divisible,
          lock: event.params.lock,
          reset: event.params.reset,
        ),
        composeFn: composeRepository.composeIssuanceVerbose,
      );

      emit(state.copyWith(
          submitState: ReviewStep<ComposeIssuanceResponseVerbose,
              ComposeIssuanceEventParams>(
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
          submitState: PasswordStep<ComposeIssuanceResponseVerbose>(
        loading: false,
        error: null,
        composeTransaction: event.composeTransaction,
        fee: event.fee,
      )));
      return;
    }

    final s = (state.submitState as ReviewStep<ComposeIssuanceResponseVerbose,
        ComposeIssuanceEventParams>);

    try {
      emit(state.copyWith(submitState: s.copyWith(loading: true)));

      final inMemoryKey = await inMemoryKeyRepository.get();

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: InMemoryKey(inMemoryKey!),
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
    if (state.submitState is! PasswordStep<ComposeIssuanceResponseVerbose>) {
      return;
    }

    final s =
        (state.submitState as PasswordStep<ComposeIssuanceResponseVerbose>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeIssuanceResponseVerbose>(
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
              submitState: PasswordStep<ComposeIssuanceResponseVerbose>(
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
