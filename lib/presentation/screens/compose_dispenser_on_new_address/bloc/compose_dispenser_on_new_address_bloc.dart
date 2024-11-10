import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_transaction_usecase.dart';
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
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignTransactionUseCase signTransactionUseCase;
  final TransactionService transactionService;

  ComposeDispenserOnNewAddressBloc({
    required this.accountRepository,
    required this.addressRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.composeRepository,
    required this.bitcoindService,
    required this.utxoRepository,
    required this.composeTransactionUseCase,
    required this.signTransactionUseCase,
    required this.transactionService,
  }) : super(const ComposeDispenserOnNewAddressStateBase(
          composeDispenserOnNewAddressState:
              ComposeDispenserOnNewAddressState.collectPassword(loading: false),
          feeState: FeeState.initial(),
        )) {
    on<ComposeTransactions>((event, emit) async {
      /**
       * The steps for chaining transactions are:
       *
       * 1. collect password
       * 2. derive new account + address
       * 3. send btc to the new address to cover fees
       * 4. send the asset that will be dispensed to the new address
       * 5. create the dispenser on the new address
       *
       * The actual chaining occurs from signing + decoding each tx and passing the output of the tx as the input for the following tx
       * The first 2 transactions are sent with 0 fee, and the last transaction is sent with a fee to cover the cost of all transactions. This works bc of the nature of chaining the transactions.
       */
      emit(state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword(
                  loading: true)));
      final wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(state.copyWith(composeDispenserOnNewAddressState:
            const ComposeDispenserOnNewAddressState.error('Wallet not found')));
        return;
      }

      String? decryptedPrivKey;
      try {
        decryptedPrivKey = await encryptionService.decrypt(
            wallet.encryptedPrivKey, event.password);
      } catch (e) {
        emit(state.copyWith(composeDispenserOnNewAddressState:
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
        accountIndex: newAccountIndex.toString(),
        walletUuid: wallet.uuid,
        name: 'Account $newAccountIndex',
        uuid: uuid.v4(),
        purpose: highestIndexAccount.purpose,
        coinType: highestIndexAccount.coinType,
        importFormat: highestIndexAccount.importFormat,
      );
      final Address newAddress = await addressService.deriveAddressSegwit(
        privKey: decryptedPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        accountUuid: newAccount.uuid,
        purpose: newAccount.purpose,
        coin: newAccount.coinType,
        account: newAccount.accountIndex,
        change: '0',
        index: 0,
      );

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

        final feeToCoverAllTransactions = event.feeRate *
            ADJUSTED_VIRTUAL_SIZE; // estimated fee to cover all transactions and the amount of btc to be sent to the new address to cover these fees

        // Step 2. Send btc to the new address to cover fees
        final bitcoinSendResponse = await composeTransactionUseCase
            .call<ComposeSendParams, ComposeSendResponse>(
          feeRate: 3, // minrelaytxfee  is 0.00001 BTC / Kb (1 satoshi/byte)
          source: source,
          params: ComposeSendParams(
            source: source,
            destination: destination,
            asset: 'BTC',
            quantity: feeToCoverAllTransactions,
          ),
          composeFn: composeRepository.composeSendVerbose,
        );

        final bitcoinSend = bitcoinSendResponse.$1;
        final virtualSize = bitcoinSendResponse.$2;

        // sign + decode the btc send
        final signedBitcoinSendHex = await signTransactionUseCase.call(
          source: source,
          rawtransaction: bitcoinSend.rawtransaction,
          password: event.password,
        );

        emit(state.copyWith(signedBtcSend: signedBitcoinSendHex));
        // final virtualSize = transactionService.getVirtualSize(bitcoinSend.rawtransaction);

        // final sigops = transactionService.countSigOps(
        //   rawtransaction: bitcoinSend.rawtransaction,
        // );

        final feeForAssetSend = virtualSize.adjustedVirtualSize * 1;
        // final adjustedVirtualSizeBtcSend = max(virtualSize, sigops * 5);

        final decodedSignedBitcoinSend =
            await bitcoindService.decoderawtransaction(signedBitcoinSendHex);

        // Step 3. Send the asset that will be dispensed to the new address
        final assetSendResponse = await composeRepository.composeSendChain(
          400,
          decodedSignedBitcoinSend,
          'BTC',
          ComposeSendParams(
            source: source,
            destination: destination,
            asset: assetToSend,
            quantity: escrowQuantityToSend,
          ),
        );

        // sign + decode the asset send
        final signedAssetSendHex = await signTransactionUseCase.call(
          source: source,
          rawtransaction: assetSendResponse.rawtransaction,
          password: event.password,
          prevDecodedTransaction: decodedSignedBitcoinSend,
          prevAssetSend: 'BTC',
        );

        emit(state.copyWith(signedAssetSend: signedAssetSendHex));

        final decodedSignedAssetSend =
            await bitcoindService.decoderawtransaction(signedAssetSendHex);

        // final virtualSizeAssetSend = transactionService.getVirtualSize(assetSendResponse.rawtransaction);

        // final sigopsAssetSend = transactionService.countSigOps(
        //   rawtransaction: assetSendResponse.rawtransaction,
        // );

        // final adjustedVirtualSizeAssetSend = max(virtualSizeAssetSend, sigopsAssetSend * 5);


        // Now that we have some actual virtual sizes, we can adjust the fee to cover all transactions. They should be smaller than the original estimated fee
        // final adjustedFeeToCoverAllTransactions = event.feeRate *
        //     (adjustedVirtualSizeBtcSend + adjustedVirtualSizeAssetSend + 300); // 300 is an overestimated guess for the dispenser send

        // if (adjustedFeeToCoverAllTransactions > estimatedFeeToCoverAllTransactions) {
        //   // TODO: fix
        //   emit(state.copyWith(composeDispenserOnNewAddressState:
        //       const ComposeDispenserOnNewAddressState.error(
        //               'Fee too low to cover all transactions')));
        //   return;
        // }
        // final adjustedFeeForDispenser = adjustedVirtualSizeAssetSend * event.feeRate;

        // Step 4. Create the dispenser on the new address
        final ComposeDispenserResponseVerbose composeDispenserResponse =
            await composeRepository.composeDispenserChain(
          600,
          decodedSignedAssetSend,
          ComposeDispenserParams(
            source: destination, // open dispenser on the new address
            asset: assetToSend,
            giveQuantity: assetQuantityToDispense,
            escrowQuantity: escrowQuantityToSend,
            mainchainrate: mainchainrate,
            status: 0,
          ),
        );

        // sign the dispenser
        final signedDispenserHex = await signTransactionUseCase.call(
          source: destination,
          rawtransaction: composeDispenserResponse.rawtransaction,
          password: event.password,
          prevDecodedTransaction: decodedSignedAssetSend,
          addressPrivKey: newAddressPrivKey,
          prevAssetSend: assetToSend,
        );

        emit(state.copyWith(signedDispenser: signedDispenserHex));

        emit(state.copyWith(composeDispenserOnNewAddressState:
            ComposeDispenserOnNewAddressState.confirm(
                    newAccountName: newAccount.name,
                    newAddress: newAddress.address,
                    composeSendTransaction1: bitcoinSend,
                    composeSendTransaction2: assetSendResponse,
                    composeDispenserTransaction: composeDispenserResponse,
                    fee: feeToCoverAllTransactions)));
      } on SignTransactionException catch (e) {
        emit(state.copyWith(composeDispenserOnNewAddressState:
            ComposeDispenserOnNewAddressState.error(e.message)));
      } catch (e) {
        emit(state.copyWith(composeDispenserOnNewAddressState:
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
      print('DO WE GET HERE???');
      await accountRepository.insert(state.newAccount!);
      await addressRepository.insert(state.newAddress!);


      print('AFTER INSERT');

      await bitcoindService.sendrawtransaction(state.signedBtcSend!);

      Future.delayed(const Duration(seconds: 10));
      await bitcoindService.sendrawtransaction(state.signedAssetSend!);

      Future.delayed(const Duration(seconds: 10));
      await bitcoindService.sendrawtransaction(state.signedDispenser!);

      print('AFTER SEND');

      emit(state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.success()));
    });
  }
}
