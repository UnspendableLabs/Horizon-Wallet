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
    required DecodedTx prevDecodedTransaction,
    required String addressPrivKey,
  }) async {
    try {
      // final voutIndex = prevAssetSend == 'BTC' ? 0 : 1;
      // for chaining transactions, we construct the utxo to use based on the previous transaction output
      // final vout0 = prevDecodedTransaction.vout[0];
      // final vout1 = prevDecodedTransaction.vout[1];
      final vout = prevDecodedTransaction.vout
          .firstWhere((vout) => vout.scriptPubKey.address == source);
      final utxosToSign = [
        // Utxo(
        //     txid: prevDecodedTransaction.txid,
        //     vout: vout0.n,
        //     height: null,
        //     value: (vout0.value * 100000000).toInt(),
        //     address: vout1.scriptPubKey.address!),
        Utxo(
            txid: prevDecodedTransaction.txid,
            vout: vout.n,
            height: null,
            value: (vout.value * 100000000).toInt(),
            address: vout.scriptPubKey.address!)
      ];

      /**
       * utxosToSign
       * List (2 items)
       */
      final Map<String, Utxo> utxoMap = {for (var e in utxosToSign) e.txid: e};

      // Sign Transaction
      final signedTransaction = await transactionService.signTransaction(
        rawtransaction,
        addressPrivKey,
        source,
        utxoMap,
      );

      return signedTransaction;
    } catch (e) {
      throw SignTransactionException('Failed to sign transaction: $e');
    }
  }
}
