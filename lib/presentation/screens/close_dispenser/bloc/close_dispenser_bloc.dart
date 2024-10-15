import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_state.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:logger/logger.dart';

class CloseDispenserParams {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;

  CloseDispenserParams({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  });
}

class CloseDispenserBloc extends ComposeBaseBloc<CloseDispenserState> {
  final Logger logger = Logger();
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;

  final FetchCloseDispenserFormDataUseCase fetchCloseDispenserFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  CloseDispenserBloc({
    required this.fetchCloseDispenserFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
  }) : super(CloseDispenserState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          dispensersState: const DispenserState.initial(),
        )) {
    // // Event handlers specific to the dispenser
    // on<ChangeAsset>((e, emit) {});
    // on<ChangeGiveQuantity>((e, emit) {});
    // on<ChangeEscrowQuantity>((e, emit) {});
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dispensersState: const DispenserState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (feeEstimates, dispensers) =
          await fetchCloseDispenserFormDataUseCase.call(event.currentAddress!);

      emit(state.copyWith(
        balancesState: const BalancesState.success([]),
        feeState: FeeState.success(feeEstimates),
        dispensersState: DispenserState.success(dispensers),
      ));
    } on FetchDispenserException catch (e) {
      emit(state.copyWith(
        dispensersState: DispenserState.error(e.message),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        dispensersState: DispenserState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final asset = event.params.asset;
      final giveQuantity = event.params.giveQuantity;
      final escrowQuantity = event.params.escrowQuantity;
      final mainchainrate = event.params.mainchainrate;

      final composed = await composeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: feeRate,
              source: source,
              params: ComposeDispenserParams(
                  source: source,
                  asset: asset,
                  giveQuantity: giveQuantity,
                  escrowQuantity: escrowQuantity,
                  mainchainrate: mainchainrate,
                  status: 10),
              composeFn: composeRepository.composeDispenserVerbose);

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeDispenserResponseVerbose>(
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
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
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
        is! SubmitFinalizing<ComposeDispenserResponseVerbose>) {
      return;
    }

    final s = (state.submitState
        as SubmitFinalizing<ComposeDispenserResponseVerbose>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        password: event.password,
        extractParams: () {
          final source = compose.params.source;
          final rawTx = compose.rawtransaction;
          final destination = source;
          final giveQuantity = compose.params.giveQuantity;
          final asset = compose.params.asset;

          return (source, rawTx, destination, giveQuantity, asset);
        },
        onSuccess:
            (txHex, txHash, source, destination, giveQuantity, asset) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.d('dispenser broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_dispenser');
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
