import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_movetoutxo/bloc/compose_movetoutxo_state.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class ComposeMoveToUtxoEventParams {
  final String utxo;
  final String destination;

  ComposeMoveToUtxoEventParams({
    required this.utxo,
    required this.destination,
  });
}

class ComposeMoveToUtxoBloc extends ComposeBaseBloc<ComposeMoveToUtxoState> {
  final txName = 'move_to_utxo';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;

  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  ComposeMoveToUtxoBloc({
    required this.logger,
    required this.passwordRequired,
    required this.inMemoryKeyRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
  }) : super(
          ComposeMoveToUtxoState(
            submitState: const FormStep(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            utxoAddress: '',
          ),
          composePage: 'compose_movetoutxo',
        );

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      submitState: const FormStep(),
    ));

    try {
      final feeEstimates = await getFeeEstimatesUseCase.call();

      emit(state.copyWith(
        feeState: FeeState.success(feeEstimates),
        balancesState: const BalancesState.success([]),
        utxoAddress: event.currentAddress!,
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
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
  void onFormSubmitted(FormSubmitted event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final utxo = event.params.utxo;
      final destination = event.params.destination;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeMoveToUtxoParams, ComposeMoveToUtxoResponse>(
              feeRate: feeRate,
              source: source,
              params:
                  ComposeMoveToUtxoParams(utxo: utxo, destination: destination),
              composeFn: composeRepository.composeMoveToUtxo);

      emit(state.copyWith(
          submitState: ReviewStep<ComposeMoveToUtxoResponse, void>(
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
          submitState: PasswordStep<ComposeMoveToUtxoResponse>(
        loading: false,
        error: null,
        composeTransaction: event.composeTransaction,
        fee: event.fee,
      )));
      return;
    }

    final s =
        (state.submitState as ReviewStep<ComposeMoveToUtxoResponse, void>);

    try {
      emit(state.copyWith(submitState: s.copyWith(loading: true)));

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: InMemoryKey(),
          source: state.utxoAddress!,
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
    if (state.submitState is! PasswordStep<ComposeMoveToUtxoResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeMoveToUtxoResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeMoveToUtxoResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        decryptionStrategy: Password(event.password),
        source: state.utxoAddress!,
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
              submitState: PasswordStep<ComposeMoveToUtxoResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);
  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
