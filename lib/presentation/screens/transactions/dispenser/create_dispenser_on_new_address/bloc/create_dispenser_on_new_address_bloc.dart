import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/get_fee_option.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/bloc/create_dispenser_on_new_address_event.dart';

// similar dispenser adjusted vsize is ~193, we add plenty of wiggle room
const int ADJUSTED_VIRTUAL_SIZE = 300;

class ComposeChainedDispenserResponse {
  final String sourceAddress;
  final String signedDispenser;
  final String signedAssetSend;
  final ComposeSendResponse assetSend;
  final ComposeDispenserResponseVerbose composeDispenser;
  final Account newAccount;
  final Address newAddress;
  final int btcQuantity;
  final num feeRate;

  ComposeChainedDispenserResponse({
    required this.sourceAddress,
    required this.signedDispenser,
    required this.signedAssetSend,
    required this.assetSend,
    required this.composeDispenser,
    required this.newAccount,
    required this.newAddress,
    required this.btcQuantity,
    required this.feeRate,
  });
}

class CreateDispenserOnNewAddressData {
  final MultiAddressBalance btcBalances;

  CreateDispenserOnNewAddressData({required this.btcBalances});
}

class CreateDispenserOnNewAddressBloc extends Bloc<
    TransactionEvent,
    TransactionState<CreateDispenserOnNewAddressData,
        ComposeChainedDispenserResponse>> {
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final Logger logger;
  final SettingsRepository settingsRepository;
  final WalletRepository walletRepository;
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final DispenserRepository dispenserRepository;
  final TransactionService transactionService;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final UtxoRepository utxoRepository;
  final BitcoindService bitcoindService;
  final ErrorService errorService;
  final SignChainedTransactionUseCase signChainedTransactionUseCase;
  CreateDispenserOnNewAddressBloc({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
    required this.walletRepository,
    required this.addressRepository,
    required this.accountRepository,
    required this.encryptionService,
    required this.addressService,
    required this.dispenserRepository,
    required this.transactionService,
    required this.inMemoryKeyRepository,
    required this.utxoRepository,
    required this.bitcoindService,
    required this.errorService,
    required this.signChainedTransactionUseCase,
  }) : super(TransactionState<CreateDispenserOnNewAddressData,
            ComposeChainedDispenserResponse>(
          formState: TransactionFormState<CreateDispenserOnNewAddressData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<CreateDispenserOnNewAddressDependenciesRequested>(
        _onDependenciesRequested);
    on<CreateDispenserOnNewAddressComposed>(_onTransactionComposed);
    on<CreateDispenserOnNewAddressTransactionBroadcasted>(
        _onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    CreateDispenserOnNewAddressDependenciesRequested event,
    Emitter<
            TransactionState<CreateDispenserOnNewAddressData,
                ComposeChainedDispenserResponse>>
        emit,
  ) async {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dataState: const TransactionDataState.loading(),
      ),
    ));

    try {
      final balances = await balanceRepository.getBalancesForAddressesAndAsset(
          event.addresses, event.assetName, BalanceType.address);

      final feeEstimates = await getFeeEstimatesUseCase.call();

      final List<String> balanceAddresses =
          balances.entries.map((entry) => entry.address!).toList();

      final btcBalances =
          await balanceRepository.getBtcBalancesForAddresses(balanceAddresses);

      emit(
        state.copyWith(
          formState: state.formState.copyWith(
            balancesState: BalancesState.success(balances),
            feeState: FeeState.success(feeEstimates),
            dataState: TransactionDataState.success(
                CreateDispenserOnNewAddressData(btcBalances: btcBalances)),
          ),
        ),
      );
    } catch (e) {
      logger.error('Error getting dependencies: $e');
      emit(
        state.copyWith(
          formState: state.formState.copyWith(
            balancesState: BalancesState.error(e.toString()),
            feeState: FeeState.error(e.toString()),
            dataState: TransactionDataState.error(e.toString()),
          ),
        ),
      );
    }
  }

  void _onTransactionComposed(
    CreateDispenserOnNewAddressComposed event,
    Emitter<
            TransactionState<CreateDispenserOnNewAddressData,
                ComposeChainedDispenserResponse>>
        emit,
  ) async {
    /**
       * The steps for chaining transactions are:
       *
       * 1. collect password
       * 2. derive new account + address
       * 3. compose the asset send
       * 4. construct a new transaction using the compose send inputs; add outputs 1. OP_RETURN, 2. BTC to send to the new address, 3. change output; sign the constructed transaction
       * 5. create the dispenser on the new address
       *
       * The actual chaining occurs from signing + decoding each tx and passing the output of the previous tx as the input for the following tx
       * The first transaction is sent with low fee, and the last transaction is sent with a higher fee. This nature of chaining allows the second tx to impose an "efective" fee on both txs
    */
    emit(state.copyWith(
      composeState: const ComposeState.loading(),
    ));
    final wallet = await walletRepository.getCurrentWallet();

    if (wallet == null) {
      emit(state.copyWith(
          composeState:
              const ComposeState.error('invariant: wallet not found')));
      return;
    }

    String? decryptedPrivKey;

    if (event.decryptionStrategy is Password) {
      try {
        decryptedPrivKey = await encryptionService.decrypt(
            wallet.encryptedPrivKey,
            (event.decryptionStrategy as Password).password);
      } catch (e) {
        emit(state.copyWith(
            composeState:
                const ComposeState.error('invariant: invalid password')));
        return;
      }
    } else {
      String? inMemoryKey = await inMemoryKeyRepository.get();
      decryptedPrivKey = await encryptionService.decryptWithKey(
          wallet.encryptedPrivKey, inMemoryKey!);
    }

    // emit(state.copyWith(password: event.password));

    // Step 1. Derive new account + address
    final List<Account> accountsInWallet =
        await accountRepository.getAccountsByWalletUuid(wallet.uuid);
    final highestIndexAccount = getHighestIndexAccount(accountsInWallet);
    final int newAccountIndex =
        int.parse(highestIndexAccount.accountIndex.replaceAll('\'', '')) + 1;
    final Account newAccount = Account(
      accountIndex: "$newAccountIndex'",
      walletUuid: wallet.uuid,
      name: 'Dispenser for ${event.params.asset}',
      uuid: uuid.v4(),
      purpose: highestIndexAccount.purpose,
      coinType: highestIndexAccount.coinType,
      importFormat: highestIndexAccount.importFormat,
    );

    Address? newAddress;
    switch (newAccount.importFormat) {
      case ImportFormat.horizon:
        newAddress = await addressService.deriveAddressSegwit(
          privKey: decryptedPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          accountUuid: newAccount.uuid,
          purpose: newAccount.purpose,
          coin: newAccount.coinType,
          account: newAccount.accountIndex,
          change: '0',
          index: 0,
        );
      case ImportFormat.freewallet:
        final addresses = await addressService.deriveAddressFreewalletRange(
          type: AddressType.bech32,
          privKey: decryptedPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          accountUuid: newAccount.uuid,
          account: newAccount.accountIndex,
          change: '0',
          start: 0,
          end: 0,
        );
        newAddress = addresses.first;
      case ImportFormat.counterwallet:
        final addresses = await addressService.deriveAddressFreewalletRange(
          type: AddressType.bech32,
          privKey: decryptedPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          accountUuid: newAccount.uuid,
          account: newAccount.accountIndex,
          change: '0',
          start: 0,
          end: 0,
        );
        newAddress = addresses.first;
    }

    final newAddressBalances =
        await balanceRepository.getBalancesForAddress(newAddress.address, true);
    final newAddressDispensers = await dispenserRepository
        .getDispensersByAddress(newAddress.address)
        .run()
        .then((either) => either.fold(
              (error) => throw Exception(
                  'unable to fetch dispensers for new address'), // Handle failure
              (dispensers) => dispensers, // Handle success
            ));

    // the point of this flow is to open a dispenser on an unused address
    // if no balances are found, the balances repository returns only a BTC balance of 0
    // TODO: WE SHOULD GET RID OF THIS CHECK
    if (newAddressBalances.length > 1 ||
        (newAddressBalances.length == 1 &&
            newAddressBalances.first.asset == 'BTC' &&
            newAddressBalances.first.quantity > 0) ||
        newAddressDispensers.isNotEmpty) {
      emit(state.copyWith(
          composeState: const ComposeState.error(
              "Next account to be created in the HD wallet is not empty. Please trigger the automatic account detection workflow here, then try again.")));
      return;
    }

    final newAddressPrivKey = await addressService.deriveAddressPrivateKey(
      rootPrivKey: decryptedPrivKey,
      chainCodeHex: wallet.chainCodeHex,
      purpose: newAccount.purpose,
      coin: newAccount.coinType,
      account: newAccount.accountIndex,
      change: '0',
      index: 0,
      importFormat: newAccount.importFormat,
    );

    // emit(state.copyWith(newAccount: newAccount, newAddress: newAddress));

    final sourceAddress =
        await addressRepository.getAddress(event.sourceAddress);
    final sourceAccount =
        await accountRepository.getAccountByUuid(sourceAddress!.accountUuid);
    final sourceAddressPrivKey = await addressService.deriveAddressPrivateKey(
      rootPrivKey: decryptedPrivKey,
      chainCodeHex: wallet.chainCodeHex,
      purpose: sourceAccount!.purpose,
      coin: sourceAccount.coinType,
      account: sourceAccount.accountIndex,
      change: '0',
      index: sourceAddress.index,
      importFormat: sourceAccount.importFormat,
    );

    try {
      final source = event
          .sourceAddress; // the current address which has the btc + asset to be dispensed
      final destination = newAddress.address; // the new address
      final assetToSend =
          event.params.asset; // the asset that will be dispensed
      final assetQuantityToDispense =
          event.params.giveQuantity; // the quantity of each dispense
      final escrowQuantityToSend = event.params
          .escrowQuantity; // the total asset quantity to be sent to the new address for the dispenser
      final mainchainrate = event.params.mainchainrate;

      final feeRate = getFeeRate(state);

      int feeToCoverDispenser = (feeRate * ADJUSTED_VIRTUAL_SIZE).ceil();
      int extraBtcToSendToDispenser = 0;

      if (event.params.sendExtraBtcToDispenser) {
        extraBtcToSendToDispenser = (feeRate * ADJUSTED_VIRTUAL_SIZE).ceil();
      }

      final feeEstimates = state.formState.getFeeEstimatesOrThrow();
      final slowFeeRate = feeEstimates.slow;

      // 2. compose the asset send
      final assetSend = await composeTransactionUseCase
          .call<ComposeSendParams, ComposeSendResponse>(
        feeRate:
            slowFeeRate, // first tx is sent with slow fee and the next tx will adjust the fee for both
        source: source,
        params: ComposeSendParams(
          source: source,
          destination: destination,
          asset: assetToSend,
          quantity: escrowQuantityToSend,
        ),
        composeFn: composeRepository.composeSendVerbose,
      );
      final feeForAssetSend = assetSend.btcFee;

      final (utxos, cachedTxHashes) = await utxoRepository
          .getUnspentForAddress(source, excludeCached: true);

      if (utxos.isEmpty) {
        final error = Exception('No UTXOs available for transaction');
        errorService.captureException(error,
            message: 'No UTXOs available for transaction',
            context: {
              'source': source,
              'cachedTxHashes': cachedTxHashes,
            });
        throw Exception('No UTXOs available for transaction');
      }

      // 3. re-construct the asset send
      final signedConstructedAssetSend =
          await transactionService.constructChainAndSignTransaction(
        unsignedTransaction: assetSend.rawtransaction,
        sourceAddress: source,
        utxos: utxos,
        sourcePrivKey: sourceAddressPrivKey,
        destinationAddress: newAddress.address,
        destinationPrivKey: newAddressPrivKey,
        btcQuantity: feeToCoverDispenser + extraBtcToSendToDispenser,
        fee: feeForAssetSend,
      );

      final decodedConstructedAssetSend = await bitcoindService
          .decoderawtransaction(signedConstructedAssetSend);

      // 4. compose the dispenser
      final composeDispenserChain =
          await composeRepository.composeDispenserChain(
        feeToCoverDispenser,
        decodedConstructedAssetSend,
        ComposeDispenserParams(
          source: destination,
          asset: assetToSend,
          giveQuantity: assetQuantityToDispense,
          escrowQuantity: escrowQuantityToSend,
          mainchainrate: mainchainrate,
          status: 0,
        ),
      );

      // 5. sign the dispenser
      final signedComposeDispenserChain =
          await signChainedTransactionUseCase.call(
        source: destination,
        rawtransaction: composeDispenserChain.rawtransaction,
        prevDecodedTransaction: decodedConstructedAssetSend,
        addressPrivKey: newAddressPrivKey,
      );

      emit(state.copyWith(
          composeState: ComposeState.success(ComposeChainedDispenserResponse(
              sourceAddress: source,
              signedDispenser: signedComposeDispenserChain,
              signedAssetSend: signedConstructedAssetSend,
              assetSend: assetSend,
              composeDispenser: composeDispenserChain,
              newAccount: newAccount,
              newAddress: newAddress,
              btcQuantity: feeToCoverDispenser + extraBtcToSendToDispenser,
              feeRate: slowFeeRate))));
    } on SignTransactionException catch (e) {
      emit(state.copyWith(composeState: ComposeState.error(e.message)));
    } on TransactionServiceException catch (e) {
      emit(state.copyWith(composeState: ComposeState.error(e.message)));
    } catch (e) {
      emit(state.copyWith(
          composeState: ComposeState.error(e is ComposeTransactionException
              ? e.message
              : 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  void _onTransactionBroadcasted(
    CreateDispenserOnNewAddressTransactionBroadcasted event,
    Emitter<
            TransactionState<CreateDispenserOnNewAddressData,
                ComposeChainedDispenserResponse>>
        emit,
  ) async {}

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<
            TransactionState<CreateDispenserOnNewAddressData,
                ComposeChainedDispenserResponse>>
        emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
