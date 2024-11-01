import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
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
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;

  final FetchDispenserFormDataUseCase fetchDispenserFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  ComposeDispenserBloc({
    required this.accountRepository,
    required this.addressRepository,
    required this.walletRepository,
    required this.fetchDispenserFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.encryptionService,
    required this.addressService,
  }) : super(ComposeDispenserState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          giveQuantity: '',
          escrowQuantity: '',
          mainchainrate: '',
          status: 0,
          dispensersState: const DispenserState.initial(),
        )) {
    // Event handlers specific to the dispenser
    on<ChangeAsset>(_onChangeAsset);
    on<ChangeGiveQuantity>(_onChangeGiveQuantity);
    on<ChangeEscrowQuantity>(_onChangeEscrowQuantity);
    on<ChooseWorkFlow>(_onChooseWorkFlow);
    on<ConfirmTransactionOnNewAddress>(_onConfirmTransactionOnNewAddress);
    // on<CollectPassword>(_onCollectPassword);
    // on<ConfirmCreateNewAddressFlow>(_onConfirmCreateNewAddressFlow);
    // on<CancelCreateNewAddressFlow>(_onCancelCreateNewAddressFlow);
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
        dispensersState: const DispenserState.successNormalFlow(),
      ));
    } else {
      emit(state.copyWith(
        dispensersState: const DispenserState.successCreateNewAddressFlow(),
      ));
    }
  }

  _onConfirmTransactionOnNewAddress(
      ConfirmTransactionOnNewAddress event, emit) {
    emit(state.copyWith(
      dispensersState: const DispenserState.successCreateNewAddressFlow(),
    ));
  }

  // _onCollectPassword(CollectPassword event, emit) async {
  //   emit(state.copyWith(
  //     dispensersState: const DispenserState.createNewAddressFlowLoading(),
  //   ));

  //   final Wallet? wallet = await walletRepository.getCurrentWallet();
  //   if (wallet == null) {
  //     throw Exception("invariant: wallet is null");
  //   }

  //   String? decryptedPrivKey;
  //   try {
  //     decryptedPrivKey = await encryptionService.decrypt(wallet.encryptedPrivKey, event.password);
  //   } catch (e) {
  //     emit(state.copyWith(
  //       dispensersState: const DispenserState.createNewAddressFlowCollectPassword(error: 'Incorrect password'),
  //     ));
  //     return;
  //   }
  //   final List<Account> accounts = await accountRepository.getAccountsByWalletUuid(wallet.uuid);
  //   final Account highestIndexAccount = getHighestIndexAccount(accounts);

  //   final int newAccountIndex = int.parse(highestIndexAccount.accountIndex.replaceAll("'", "")) + 1;

  //   final account = Account(
  //     name: 'Dispenser Account',
  //     uuid: uuid.v4(),
  //     walletUuid: wallet.uuid,
  //     purpose: highestIndexAccount.purpose,
  //     coinType: highestIndexAccount.coinType,
  //     accountIndex: newAccountIndex.toString(),
  //     importFormat: highestIndexAccount.importFormat,
  //   );
  //   final address = await addressService.deriveAddressSegwit(
  //       privKey: decryptedPrivKey,
  //       chainCodeHex: wallet.chainCodeHex,
  //       accountUuid: account.uuid,
  //       purpose: account.purpose,
  //       coin: account.coinType,
  //       account: account.accountIndex,
  //       change: '0',
  //       index: 0);

  //   emit(state.copyWith(
  //     dispensersState: DispenserState.createNewAddressFlowConfirmation(account: account, address: address),
  //   ));
  // }

  // _onConfirmCreateNewAddressFlow(ConfirmCreateNewAddressFlow event, emit) {
  //   emit(state.copyWith(
  //     dispensersState: const DispenserState.successCreateNewAddressFlow(),
  //   ));
  // }

  // _onCancelCreateNewAddressFlow(CancelCreateNewAddressFlow event, emit) {
  //   emit(state.copyWith(
  //     dispensersState: const DispenserState.warning(),
  //   ));
  // }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dispensersState: const DispenserState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (balances, feeEstimates, dispensers) =
          await fetchDispenserFormDataUseCase.call(event.currentAddress!);

      if (dispensers.isEmpty) {
        emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dispensersState: const DispenserState.successNormalFlow(),
        ));
      } else {
        emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dispensersState: const DispenserState.warning(),
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
        dispensersState: DispenserState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
        dispensersState: DispenserState.error(
            'An unexpected error occurred: ${e.toString()}'),
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

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState:
              SubmitComposingTransaction<ComposeDispenserResponseVerbose, void>(
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

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));

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
