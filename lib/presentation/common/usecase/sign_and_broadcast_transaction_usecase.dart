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
  });

  Future<void> call({
    required String password,
    required Function() extractParams,
    required Function(String, String, String?, String?, int?, String?)
        onSuccess,
    required Function(String) onError,
  }) async {
    try {
      late String source;
      late String rawTx;
      late String destination;
      late int quantity;
      late String asset;

      // Extract parameters
      (source, rawTx, destination, quantity, asset) = extractParams();

      // Fetch UTXOs
      final utxos = await utxoRepository.getUnspentForAddress(source);
      final Map<String, Utxo> utxoMap = {for (var e in utxos) e.txid: e};

      // Fetch Address, Account, and Wallet
      final address = await addressRepository.getAddress(source);
      if (address == null) {
        throw SignAndBroadcastTransactionException('Address not found.');
      }

      final account =
          await accountRepository.getAccountByUuid(address.accountUuid);
      if (account == null) {
        throw SignAndBroadcastTransactionException('Account not found.');
      }

      final wallet = await walletRepository.getWallet(account.walletUuid);

      // Decrypt Root Private Key
      String decryptedRootPrivKey;
      try {
        decryptedRootPrivKey =
            await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
      } catch (e) {
        throw SignAndBroadcastTransactionException('Incorrect password.');
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

      // Sign Transaction
      final txHex = await transactionService.signTransaction(
        rawTx,
        addressPrivKey,
        source,
        utxoMap,
      );

      // Broadcast Transaction
      try {
        final txHash = await bitcoindService.sendrawtransaction(txHex);
        await onSuccess(txHex, txHash, source, destination, quantity, asset);
      } catch (e) {
        throw SignAndBroadcastTransactionException(
            'Failed to broadcast the transaction.');
      }
    } catch (e) {
      onError(e is SignAndBroadcastTransactionException
          ? e.message
          : 'An unexpected error occurred.');
    }
  }
}
