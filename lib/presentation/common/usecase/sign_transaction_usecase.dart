import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';

class AddressNotFoundException implements Exception {
  final String message;
  AddressNotFoundException([this.message = 'Address not found']);
}

// Custom exception class
class SignTransactionException implements Exception {
  final String message;
  SignTransactionException(
      [this.message =
          'An error occurred during the sign transaction process.']);
}

// TODO: there are a few too many deps here.
//       could add separate use case for deriving key
//       might also want to split out sign / broadcast
class SignTransactionUseCase {
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final ImportedAddressService importedAddressService;
  final UtxoRepository utxoRepository;

  SignTransactionUseCase({
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionService,
    required this.importedAddressService,
    required this.utxoRepository,
  });

  Future<String> call({
    required String password,
    required String source,
    required String rawtransaction,
    DecodedTx? prevDecodedTransaction,
    String? prevAssetSend,
    String? addressPrivKey,
  }) async {
    try {
      List<Utxo>? utxosToSign;

      if (prevDecodedTransaction != null) {
        // final voutIndex = prevAssetSend == 'BTC' ? 0 : 1;
        // for chaining transactions, we construct the utxo to use based on the previous transaction output
        // final vout0 = prevDecodedTransaction.vout[0];
        final vout1 = prevDecodedTransaction.vout[1];
        utxosToSign = [
          // Utxo(
          //     txid: prevDecodedTransaction.txid,
          //     vout: vout0.n,
          //     height: null,
          //     value: (vout0.value * 100000000).toInt(),
          //     address: vout1.scriptPubKey.address!),
          Utxo(
              txid: prevDecodedTransaction.txid,
              vout: vout1.n,
              height: null,
              value: (vout1.value * 100000000).toInt(),
              address: vout1.scriptPubKey.address!)

        ];
      } else {
        // otherwise, fetch the utxos for the source address
        List<Utxo> utxos = await utxoRepository.getUnspentForAddress(source);
        final utxo = utxos.first;
        utxosToSign = [
            Utxo(
              txid: utxo.txid,
              vout: utxo.vout,
              height: utxo.height,
              value: utxo.value,
              address: utxo.address)
        ];
      }
      /**
       * utxosToSign
       * List (2 items)
       */
      final Map<String, Utxo> utxoMap = {for (var e in utxosToSign) e.txid: e};
      String? privKey = addressPrivKey;

      if (addressPrivKey == null) {
        // Fetch Address, Account, and Wallet
        final address = await addressRepository.getAddress(source);

        if (address == null) {
          throw SignTransactionException('Address not found.');
        }

        privKey = await _getAddressPrivKeyForAddress(address, password);
      }

      // Sign Transaction
      final signedTransaction = await transactionService.signTransaction(
        rawtransaction,
        privKey!,
        source,
        utxoMap,
      );

      return signedTransaction;
    } catch (e) {
      throw SignTransactionException('Failed to sign transaction: $e');
    }
  }

  Future<String> _getAddressPrivKeyForAddress(
      Address address, String password) async {
    final account =
        await accountRepository.getAccountByUuid(address.accountUuid);
    if (account == null) {
      throw SignTransactionException('Account not found.');
    }

    final wallet = await walletRepository.getWallet(account.walletUuid);

    // Decrypt Root Private Key
    String decryptedRootPrivKey;
    try {
      decryptedRootPrivKey =
          await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
    } catch (e) {
      throw SignTransactionException('Incorrect password.');
    }

    // Derive Address Private Key
    final addressPrivKey = await addressService.deriveAddressPrivateKey(
      rootPrivKey: decryptedRootPrivKey,
      chainCodeHex: wallet.chainCodeHex,
      purpose: account.purpose,
      coin: account.coinType,
      account: account.accountIndex,
      change: '0',
      index: address.index,
      importFormat: account.importFormat,
    );

    return addressPrivKey;
  }

  // Future<String> _getAddressPrivKeyForImportedAddress(ImportedAddress importedAddress, String password) async {
  //   late String decryptedAddressWif;
  //   try {
  //     decryptedAddressWif = await encryptionService.decrypt(importedAddress.encryptedWif, password);
  //   } catch (e) {
  //     throw SignTransactionException('Incorrect password.');
  //   }

  //   final addressPrivKey = await importedAddressService.getAddressPrivateKeyFromWIF(wif: decryptedAddressWif);

  //   return addressPrivKey;
  // }
}
