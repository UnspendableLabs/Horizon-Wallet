import 'package:horizon/common/uuid.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_order/bloc/compose_order_event.dart';

import "./compose_order_state.dart";
// import "./compose_order_event.dart";

class ComposeOrderEventParams {
  final int feeRate;
  final String giveAsset;
  final int giveQuantity;
  final String getAsset;
  final int getQuantity;
  ComposeOrderEventParams({
    required this.feeRate,
    required this.giveAsset,
    required this.giveQuantity,
    required this.getAsset,
    required this.getQuantity,
  });
}

class ComposeOrderBloc extends ComposeBaseBloc<ComposeOrderState> {
  final Logger logger;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;

  ComposeOrderBloc({
    required this.logger,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.getFeeEstimatesUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
  }) : super(
          ComposeOrderState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
          ),
          composePage: 'compose_order',
        ) {
    on<ComposeResponseReceived>(_handleComposeResponseReceived);
    on<ConfirmationBackButtonPressed>(_handleConfirmationBackButtonPressed);
  }

  @override
  Future<void> onFetchFormData(FetchFormData event, emit) async {
    // delegated to fom
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    // delegated to fom
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    // delegated to form bloc
  }

  void _handleComposeResponseReceived(
      ComposeResponseReceived event, emit) async {
    emit(state.copyWith(
        submitState: SubmitComposingTransaction<ComposeOrderResponse, void>(
      composeTransaction: event.response,
      fee: event.response.btcFee,
      feeRate: event.feeRate,
      virtualSize: event.virtualSize.virtualSize,
      adjustedVirtualSize: event.virtualSize.adjustedVirtualSize,
    )));
  }

  void _handleConfirmationBackButtonPressed(
      ConfirmationBackButtonPressed event, emit) async {
    emit(state.copyWith(submitState: const SubmitInitial()));
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeOrderResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeOrderResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeOrderResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeOrderResponse>(
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

          analyticsService.trackAnonymousEvent('broadcast_tx_order',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeOrderResponse>(
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
