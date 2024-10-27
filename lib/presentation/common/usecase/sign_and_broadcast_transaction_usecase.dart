import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/presentation/common/usecase/batch_update_address_pks.dart';

class AddressNotFoundException implements Exception {
  final String message;
  AddressNotFoundException([this.message = 'Address not found']);
}

// Custom exception class
class SignAndBroadcastTransactionException implements Exception {
  final String message;
  SignAndBroadcastTransactionException(
      [this.message =
          'An error occurred during the sign and broadcast process.']);
}

// TODO: there are a few too many deps here.
//       could add separate use case for deriving key
//       might also want to split out sign / broadcast
class SignAndBroadcastTransactionUseCase<R extends ComposeResponse> {
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final UtxoRepository utxoRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final TransactionLocalRepository transactionLocalRepository;
  final BatchUpdateAddressPksUseCase batchUpdateAddressPksUseCase;

  SignAndBroadcastTransactionUseCase({
    required this.addressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.utxoRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionService,
    required this.bitcoindService,
    required this.transactionLocalRepository,
    required this.batchUpdateAddressPksUseCase,
  });

  Future<void> call(
      {required String password,
      required Function(String, String) onSuccess,
      required Function(String) onError,
      required String source,
      required String rawtransaction}) async {
    try {
      // Fetch UTXOs
      final utxos = await utxoRepository.getUnspentForAddress(source);
      final Map<String, Utxo> utxoMap = {for (var e in utxos) e.txid: e};

      // Fetch Address, Account, and Wallet
      final address = await addressRepository.getAddress(source);
      if (address == null) {
        throw SignAndBroadcastTransactionException('Address not found.');
      }

      String addressPrivKey;
      if (address.encryptedPrivateKey != null) {
        String decryptedAddressPrivKeyWIF;
        try {
          decryptedAddressPrivKeyWIF = await encryptionService.decrypt(
              address.encryptedPrivateKey!, password);
        } catch (e) {
          throw SignAndBroadcastTransactionException('Incorrect password.');
        }

        try {
          addressPrivKey = await addressService.getAddressPrivateKeyFromWIF(
              wif: decryptedAddressPrivKeyWIF);
        } catch (e) {
          throw SignAndBroadcastTransactionException(
              'Failed to derive address private key.');
        }
      } else {
        final account =
            await accountRepository.getAccountByUuid(address.accountUuid);
        if (account == null) {
          throw SignAndBroadcastTransactionException('Account not found.');
        }

        final wallet = await walletRepository.getWallet(account.walletUuid);

        // Decrypt Root Private Key
        String decryptedRootPrivKey;
        try {
          decryptedRootPrivKey = await encryptionService.decrypt(
              wallet!.encryptedPrivKey, password);
        } catch (e) {
          throw SignAndBroadcastTransactionException('Incorrect password.');
        }

      final addressPrivKeyWIF = await addressService.getAddressWIFFromPrivateKey(
          rootPrivKey: decryptedRootPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          purpose: account.purpose,
          coin: account.coinType,
          account: account.accountIndex,
          change: '0',
          index: address.index,
          importFormat: account.importFormat,
        );


        try {
          addressPrivKey = await addressService.getAddressPrivateKeyFromWIF(wif: addressPrivKeyWIF);
        } catch (e) {
          throw SignAndBroadcastTransactionException('Failed to derive address private key.');
        }

        final encryptedAddressPrivKey = await encryptionService.encrypt(addressPrivKeyWIF, password);
        await addressRepository.updateAddressEncryptedPrivateKey(address.address, encryptedAddressPrivKey);

      }

      // Sign Transaction
      final txHex = await transactionService.signTransaction(
        rawtransaction,
        addressPrivKey,
        source,
        utxoMap,
      );

      // Broadcast Transaction
      try {
        final txHash = await bitcoindService.sendrawtransaction(txHex);
        await onSuccess(txHex, txHash);
      } catch (e) {
        final String errorMessage = 'Failed to broadcast the transaction: $e';
        throw SignAndBroadcastTransactionException(errorMessage);
      }
      await batchUpdateAddressPksUseCase.populateEncryptedPrivateKeys(password);
    } catch (e) {
      onError(e is SignAndBroadcastTransactionException
          ? e.message
          : 'An unexpected error occurred.');
    }
  }
}
