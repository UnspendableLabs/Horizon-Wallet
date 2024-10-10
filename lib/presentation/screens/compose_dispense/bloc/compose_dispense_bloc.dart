import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:logger/logger.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

class ComposeDispenseEventParams {
  final String address;
  final String dispenser;
  final int quantity;

  ComposeDispenseEventParams({
    required this.address,
    required this.dispenser,
    required this.quantity,
  });
}

class ComposeDispenseBloc extends ComposeBaseBloc<ComposeDispenseState> {
  final Logger logger = Logger();
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;

  final FetchDispenseFormDataUseCase fetchDispenseFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  ComposeDispenseBloc({
    required this.composeRepository,
    required this.analyticsService,
    required this.fetchDispenseFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
  }) : super(ComposeDispenseState(
          feeOption: FeeOption.Medium(),
          submitState: const SubmitInitial(),
          feeState: const FeeState.initial(),
          balancesState: const BalancesState.initial(),
          quantity: "",
        )) {
    // Register additional event handlers specific to sending
  }

  @override
  onChangeFeeOption(event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (balances, feeEstimates) =
          await fetchDispenseFormDataUseCase.call(event.currentAddress!);

      emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
      ));
    } on FetchBalancesException catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.message),
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
  onFinalizeTransaction(event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenseParams>(
            loading: false,
            error: null,
            composeTransaction: event.composeTransaction,
            fee: event.fee)));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final dispenser = event.params.dispenser;
      final quantity = event.params.quantity;

      logger.e("event dispenser ${event.params.dispenser}");


      final composed = await composeTransactionUseCase
          .call<ComposeDispenseParams, ComposeDispenseResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeDispenseParams(
                address: source,
                dispenser: dispenser,
                quantity: quantity,
              ),
              composeFn: composeRepository.composeDispense);

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<ComposeDispenseResponse>(
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
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState is! SubmitFinalizing<ComposeDispenseResponse>) {
      return;
    }

    final s = (state.submitState as SubmitFinalizing<ComposeDispenseResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenseResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        password: event.password,
        source: compose.params.address,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.d('dispense broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.address)));

          analyticsService.trackEvent('broadcast_tx_dispense');
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeDispenseResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
