import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
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
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

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
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final TransactionService transactionService;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;

  ComposeIssuanceBloc(
      {required this.balanceRepository,
      required this.composeRepository,
      required this.transactionService,
      required this.analyticsService,
      required this.getFeeEstimatesUseCase,
      required this.composeTransactionUseCase,
      required this.signAndBroadcastTransactionUseCase,
      required this.writelocalTransactionUseCase,
      required this.logger})
      : super(ComposeIssuanceState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            quantity: '')) {
    // Event handlers specific to issuance
    on<FetchBalances>(_onFetchBalances);
  }

  _onFetchBalances(FetchBalances event, emit) async {
    emit(state.copyWith(balancesState: const BalancesState.loading()));
    try {
      List<Balance> balances =
          await balanceRepository.getBalancesForAddress(event.address);
      emit(state.copyWith(balancesState: BalancesState.success(balances)));
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        submitState: const SubmitInitial()));

    late List<Balance> balances;
    late FeeEstimates feeEstimates;

    try {
      List<Address> addresses = [event.currentAddress!];

      balances =
          await balanceRepository.getBalancesForAddress(addresses[0].address);
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.toString()),
      ));
      return;
    }

    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        targets: (1, 3, 6),
      );
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      balancesState: BalancesState.success(balances),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

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

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<
              ComposeIssuanceResponseVerbose, ComposeIssuanceEventParams>(
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
        submitState: SubmitFinalizing<ComposeIssuanceResponseVerbose>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    if (state.submitState
        is! SubmitFinalizing<ComposeIssuanceResponseVerbose>) {
      return;
    }

    final s =
        (state.submitState as SubmitFinalizing<ComposeIssuanceResponseVerbose>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeIssuanceResponseVerbose>(
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

          logger.info('issuance broadcasted txHash: $txHash');
          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));

          analyticsService.trackEvent('broadcast_tx_issue');
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeIssuanceResponseVerbose>(
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
