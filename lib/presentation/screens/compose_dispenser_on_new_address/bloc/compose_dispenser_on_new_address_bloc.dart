import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';

// this number should cover the adjust vsize of 3 transactions: 2 sends and 1 dispenser. a similar send will hae an adjusted vsize of ~166 and a similar dispenser will have an adjusted vsize of ~193. so send1 + send2 + dispenser + plenty of wiggle room = 1000
const int ADJUSTED_VIRTUAL_SIZE = 1000;

class ComposeDispenserOnNewAddressBloc extends Bloc<
    ComposeDispenserOnNewAddressEvent, ComposeDispenserOnNewAddressStateBase> {
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ComposeRepository composeRepository;
  final BitcoindService bitcoindService;
  final UtxoRepository utxoRepository;
  final BalanceRepository balanceRepository;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignTransactionUseCase signTransactionUseCase;
  final TransactionService transactionService;
  final FetchDispenseFormDataUseCase fetchDispenseFormDataUseCase;

  ComposeDispenserOnNewAddressBloc({
    required this.accountRepository,
    required this.addressRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.composeRepository,
    required this.bitcoindService,
    required this.utxoRepository,
    required this.balanceRepository,
    required this.composeTransactionUseCase,
    required this.signTransactionUseCase,
    required this.transactionService,
    required this.fetchDispenseFormDataUseCase,
  }) : super(const ComposeDispenserOnNewAddressStateBase(
          composeDispenserOnNewAddressState:
              ComposeDispenserOnNewAddressState.collectPassword(loading: false),
          feeState: FeeState.initial(),
        )) {
    on<FetchFormData>((event, emit) async {
      emit(state.copyWith(feeState: const FeeState.loading()));

      try {
        final (balances, feeEstimates) =
            await fetchDispenseFormDataUseCase.call(event.originalAddress);

        emit(state.copyWith(
          feeState: FeeState.success(feeEstimates),
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
    });
    on<ComposeTransactions>((event, emit) async {
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
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword(
                  loading: true)));
      final wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                const ComposeDispenserOnNewAddressState.error(
                    'Wallet not found')));
        return;
      }

      String? decryptedPrivKey;
      try {
        decryptedPrivKey = await encryptionService.decrypt(
            wallet.encryptedPrivKey, event.password);
      } catch (e) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                const ComposeDispenserOnNewAddressState.collectPassword(
                    error: 'Invalid password', loading: false)));
        return;
      }

      emit(state.copyWith(password: event.password));

      // Step 1. Derive new account + address
      final List<Account> accountsInWallet =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);
      final highestIndexAccount = getHighestIndexAccount(accountsInWallet);
      final int newAccountIndex =
          int.parse(highestIndexAccount.accountIndex.replaceAll('\'', '')) + 1;
      final Account newAccount = Account(
        accountIndex: "$newAccountIndex'",
        walletUuid: wallet.uuid,
        name: 'Dispenser for ${event.asset}',
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
        default:
          throw Exception(
              'Unsupported import format: ${newAccount.importFormat}');
      }

      final newAddressBalances =
          await balanceRepository.getBalancesForAddress(newAddress.address);

      // the point of this flow is to open a dispenser on an unused address
      if (newAddressBalances.isNotEmpty) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                const ComposeDispenserOnNewAddressState.error(
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

      emit(state.copyWith(newAccount: newAccount, newAddress: newAddress));

      final sourceAddress =
          await addressRepository.getAddress(event.originalAddress);
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
            .originalAddress; // the current address which has the btc + asset to be dispensed
        final destination = newAddress.address; // the new address
        final assetToSend = event.asset; // the asset that will be dispensed
        final assetQuantityToDispense =
            event.giveQuantity; // the quantity of each dispense
        final escrowQuantityToSend = event
            .escrowQuantity; // the total asset quantity to be sent to the new address for the dispenser
        final mainchainrate = event.mainchainrate;

        final feeToCoverDispenser =
            event.feeRate * 300; // estimated fee to cover the dispenser

        // 2. compose the asset send
        final assetSend = await composeTransactionUseCase
            .call<ComposeSendParams, ComposeSendResponse>(
          feeRate: _getFeeRate(FeeOption.Slow()),
          source: source,
          params: ComposeSendParams(
            source: source,
            destination: destination,
            asset: assetToSend,
            quantity: escrowQuantityToSend,
          ),
          composeFn: composeRepository.composeSendVerbose,
        );
        final feeForAssetSend = assetSend.$1.btcFee;

        final utxos = await utxoRepository.getUnspentForAddress(source);

        // 3. re-construct the asset send
        final signedConstructedAssetSend =
            await transactionService.constructAndSignNewTransaction(
          unsignedTransaction: assetSend.$1.rawtransaction,
          sourceAddress: source,
          utxos: utxos,
          sourcePrivKey: sourceAddressPrivKey,
          destinationPrivKey: newAddressPrivKey,
          btcQuantity: feeToCoverDispenser,
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
        final signedComposeDispenserChain = await signTransactionUseCase.call(
          source: destination,
          rawtransaction: composeDispenserChain.rawtransaction,
          password: event.password,
          prevDecodedTransaction: decodedConstructedAssetSend,
          addressPrivKey: newAddressPrivKey,
        );

        emit(state.copyWith(
            signedDispenser: signedComposeDispenserChain,
            signedAssetSend: signedConstructedAssetSend,
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.confirm(
                    composeSendTransaction: assetSend.$1,
                    composeDispenserTransaction: composeDispenserChain,
                    newAccountName: state.newAccount!.name,
                    newAddress: state.newAddress!.address,
                    btcQuantity: feeToCoverDispenser,
                    feeRate: event.feeRate)));
      } on SignTransactionException catch (e) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.error(e.message)));
      } catch (e) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.error(
                    e is ComposeTransactionException
                        ? e.message
                        : 'An unexpected error occurred: ${e.toString()}')));
      }
    });
    on<BroadcastTransactions>((event, emit) async {
      emit(state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.loading()));
      try {
        await accountRepository.insert(state.newAccount!);
        await addressRepository.insert(state.newAddress!);

        Future.delayed(const Duration(seconds: 10));
        await bitcoindService.sendrawtransaction(state.signedAssetSend!);

        Future.delayed(const Duration(seconds: 10));
        await bitcoindService.sendrawtransaction(state.signedDispenser!);

        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                const ComposeDispenserOnNewAddressState.success()));
      } catch (e) {
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.error(
                    'Error broadcasting transactions: ${e.toString()}')));
      }
    });
  }

  int _getFeeRate(FeeOption.FeeOption feeOption) {
    FeeEstimates feeEstimates = state.feeState.feeEstimates;
    return switch (feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }
}