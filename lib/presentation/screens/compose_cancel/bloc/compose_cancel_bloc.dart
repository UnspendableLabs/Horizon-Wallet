import 'package:horizon/common/uuid.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_cancel/bloc/compose_cancel_event.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

import "./compose_cancel_state.dart";
// import "./compose_order_event.dart";

class ComposeCancelEventParams {
  final int feeRate;
  final String giveAsset;
  final int giveQuantity;
  final String getAsset;
  final int getQuantity;
  ComposeCancelEventParams({
    required this.feeRate,
    required this.giveAsset,
    required this.giveQuantity,
    required this.getAsset,
    required this.getQuantity,
  });
}

class ComposeCancelBloc extends ComposeBaseBloc<ComposeCancelState> {
  final txName = 'cancel_order';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final Logger logger;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;

  ComposeCancelBloc({
    required this.passwordRequired,
    required this.inMemoryKeyRepository,
    required this.logger,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.getFeeEstimatesUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
  }) : super(
          ComposeCancelState(
            submitState: const FormStep(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
          ),
          composePage: 'compose_cancel',
        ) {
    on<ComposeResponseReceived>(_handleComposeResponseReceived);
    on<ConfirmationBackButtonPressed>(_handleConfirmationBackButtonPressed);
  }

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    // delegated to fom
  }

  @override
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
    // delegated to fom
  }

  @override
  void onFormSubmitted(FormSubmitted event, emit) async {
    // delegated to form bloc
  }

  void _handleComposeResponseReceived(
      ComposeResponseReceived event, emit) async {
    emit(state.copyWith(
        submitState: ReviewStep<ComposeCancelResponse, void>(
      composeTransaction: event.response,
      fee: event.response.btcFee,
      feeRate: event.feeRate,
      virtualSize: event.virtualSize.virtualSize,
      adjustedVirtualSize: event.virtualSize.adjustedVirtualSize,
    )));
  }

  void _handleConfirmationBackButtonPressed(
      ConfirmationBackButtonPressed event, emit) async {
    emit(state.copyWith(submitState: const FormStep()));
  }

  @override
  void onReviewSubmitted(ReviewSubmitted event, emit) async {
    if (passwordRequired) {
      emit(state.copyWith(
          submitState: PasswordStep<ComposeCancelResponse>(
        loading: false,
        error: null,
        composeTransaction: event.composeTransaction,
        fee: event.fee,
      )));
      return;
    }

    final s = (state.submitState as ReviewStep<ComposeCancelResponse, void>);


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
    if (state.submitState is! PasswordStep<ComposeCancelResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeCancelResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeCancelResponse>(
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

          analyticsService.trackAnonymousEvent('broadcast_tx_cancel',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: PasswordStep<ComposeCancelResponse>(
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
