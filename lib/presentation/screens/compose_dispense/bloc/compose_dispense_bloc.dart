import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_event.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_open_dispensers_on_address.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/estimate_dispenses.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/core/logging/logger.dart';
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
  final Logger logger;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;

  final FetchOpenDispensersOnAddressUseCase fetchOpenDispensersOnAddressUseCase;
  final FetchDispenseFormDataUseCase fetchDispenseFormDataUseCase;
  final EstimateDispensesUseCase estimateDispensesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final DispenserRepository dispenserRepository;

  ComposeDispenseBloc({
    required this.logger,
    required this.fetchOpenDispensersOnAddressUseCase,
    required this.dispenserRepository,
    required this.composeRepository,
    required this.analyticsService,
    required this.fetchDispenseFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.estimateDispensesUseCase,
  }) : super(ComposeDispenseState(
          feeOption: FeeOption.Medium(),
          submitState: const SubmitInitial(),
          feeState: const FeeState.initial(),
          balancesState: const BalancesState.initial(),
          dispensersState: const DispensersState.initial(),
          quantity: "",
        )) {
    on<DispenserAddressChanged>(_onDispenserAddressChanged);
    // Register additional event handlers specific to sending
  }

  _onDispenserAddressChanged(event, emit) async {
    emit(state.copyWith(
      dispensersState: const DispensersState.loading(),
    ));

    try {
      if (event.address.isEmpty) {
        emit(state.copyWith(
          dispensersState: const DispensersState.initial(),
        ));
        return;
      }

      final dispensers =
          await fetchOpenDispensersOnAddressUseCase.call(event.address);

      emit(state.copyWith(
        dispensersState: DispensersState.success(dispensers),
      ));
    } on FetchOpenDispensersOnAddressException catch (e) {
      logger.error("An unexpected error occurred: ${e.toString()}");

      emit(state.copyWith(
        dispensersState: DispensersState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        dispensersState: DispensersState.error(
            'An unexpected error occurred: ${e.toString()}'),
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
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

    logger.warn("fetch form data ${event.initialDispenserAddress}");

    try {
      final feeEstimates =
          await fetchDispenseFormDataUseCase.call(event.currentAddress!);

      // default to initial of there is no dispenser addy
      DispensersState nextDispensersState = const DispensersState.initial();

      if (event.initialDispenserAddress != null) {
        final dispensers = await fetchOpenDispensersOnAddressUseCase
            .call(event.initialDispenserAddress!);
        nextDispensersState = DispensersState.success(dispensers);
      }

      emit(state.copyWith(
          feeState: FeeState.success(feeEstimates),
          dispensersState: nextDispensersState));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } on FetchOpenDispensersOnAddressException catch (e) {
      emit(state.copyWith(
        dispensersState: DispensersState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        dispensersState: DispensersState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  onFinalizeTransaction(event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenseResponse>(
            loading: false,
            error: null,
            composeTransaction: event.composeTransaction,
            fee: event.fee)));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      // This will throw if no dispensers are found

      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final dispenser = event.params.dispenser;
      final quantity = event.params.quantity;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeDispenseParams, ComposeDispenseResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeDispenseParams(
                address: source,
                dispenser: dispenser,
                quantity: quantity,
              ),
              composeFn: composeRepository.composeDispense);

      final dispensers = await fetchOpenDispensersOnAddressUseCase
          .call(event.params.dispenser);

      final expectedDispenses = estimateDispensesUseCase.call(
          dispensers: dispensers, quantity: event.params.quantity);

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<ComposeDispenseResponse,
              List<EstimatedDispense>>(
        composeTransaction: composed,
        fee: composed.btcFee,
        feeRate: feeRate,
        otherParams: expectedDispenses,
        virtualSize: virtualSize.virtualSize,
        adjustedVirtualSize: virtualSize.adjustedVirtualSize,
      )));
    } on FetchOpenDispensersOnAddressException {
      emit(state.copyWith(
          submitState: const SubmitInitial(
              loading: false, error: 'No open dispensers found')));
      return;
    } on ComposeTransactionException catch (e, _) {
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
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.error('dispense broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_dispense',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
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
