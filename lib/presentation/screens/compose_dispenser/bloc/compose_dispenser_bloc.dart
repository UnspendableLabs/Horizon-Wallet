import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:logger/logger.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

class ComposeDispenserEventParams {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;

  ComposeDispenserEventParams({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    this.openAddress,
    this.oracleAddress,
  });
}

class ComposeDispenserBloc extends ComposeBaseBloc<ComposeDispenserState> {
  final Logger logger = Logger();
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;

  final FetchDispenserFormDataUseCase fetchDispenserFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  ComposeDispenserBloc({
    required this.fetchDispenserFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
  }) : super(
          ComposeDispenserState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            giveQuantity: '',
            escrowQuantity: '',
            mainchainrate: '',
            status: 0,
            dialogState: const DialogState.initial(),
          ),
          composePage: 'compose_dispenser',
        ) {
    // Event handlers specific to the dispenser
    on<ChangeAsset>(_onChangeAsset);
    on<ChangeGiveQuantity>(_onChangeGiveQuantity);
    on<ChangeEscrowQuantity>(_onChangeEscrowQuantity);
    on<ChooseWorkFlow>(_onChooseWorkFlow);
    on<ConfirmTransactionOnNewAddress>(_onConfirmTransactionOnNewAddress);
  }

  _onChangeEscrowQuantity(ChangeEscrowQuantity event, emit) {
    final quantity = event.value;
    emit(state.copyWith(escrowQuantity: quantity));
  }

  _onChangeGiveQuantity(ChangeGiveQuantity event, emit) {
    final quantity = event.value;
    emit(state.copyWith(giveQuantity: quantity));
  }

  _onChangeAsset(ChangeAsset event, emit) {
    emit(state.copyWith(
      assetName: event.asset,
    ));
  }

  _onChooseWorkFlow(ChooseWorkFlow event, emit) async {
    if (!event.isCreateNewAddress) {
      emit(state.copyWith(
        dialogState: const DialogState.successNormalFlow(),
      ));
    } else {
      emit(state.copyWith(
        dialogState: const DialogState.successCreateNewAddressFlow(),
      ));
    }
  }

  _onConfirmTransactionOnNewAddress(
      ConfirmTransactionOnNewAddress event, emit) {
    final feeRate = _getFeeRate();

    emit(state.copyWith(
      dialogState: DialogState.closeDialogAndOpenNewAddress(
        originalAddress: event.originalAddress,
        divisible: event.divisible,
        asset: event.asset,
        giveQuantity: event.giveQuantity,
        escrowQuantity: event.escrowQuantity,
        mainchainrate: event.mainchainrate,
        feeRate: feeRate,
      ),
    ));
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  Future<void> onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dialogState: const DialogState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (balances, feeEstimates, dispensers) =
          await fetchDispenserFormDataUseCase.call(event.currentAddress!);

      if (dispensers.isEmpty) {
        emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dialogState: const DialogState.warning(hasOpenDispensers: false),
        ));
      } else {
        //otherwise, allow the user to choose whether to proceed or open on a new address
        emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dialogState: const DialogState.warning(hasOpenDispensers: true),
        ));
      }
    } on FetchBalancesException catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.message),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } on FetchDispenserException catch (e) {
      emit(state.copyWith(
        dialogState: DialogState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
        dialogState:
            DialogState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
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

      final composeResponse = await composeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: feeRate,
              source: source,
              params: ComposeDispenserParams(
                  source: source,
                  asset: asset,
                  giveQuantity: giveQuantity,
                  escrowQuantity: escrowQuantity,
                  mainchainrate: mainchainrate),
              composeFn: composeRepository.composeDispenserVerbose);

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeDispenserResponseVerbose, void>(
        composeTransaction: composeResponse,
        fee: composeResponse.btcFee,
        feeRate: feeRate,
        virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
        adjustedVirtualSize:
            composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
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
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.d('dispenser broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_dispenser',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
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
