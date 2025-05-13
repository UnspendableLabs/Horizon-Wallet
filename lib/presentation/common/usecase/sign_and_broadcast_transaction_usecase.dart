import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';

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
  final ImportedAddressRepository importedAddressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final UtxoRepository utxoRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final TransactionLocalRepository transactionLocalRepository;
  final ImportedAddressService importedAddressService;
  final InMemoryKeyRepository inMemoryKeyRepository;

  SignAndBroadcastTransactionUseCase({
    required this.inMemoryKeyRepository,
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.utxoRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionService,
    required this.bitcoindService,
    required this.transactionLocalRepository,
    required this.importedAddressService,
  });

  Future<void> call({
    required DecryptionStrategy decryptionStrategy,
    required Function(String, String) onSuccess,
    required Function(String) onError,
    required String source,
    required String rawtransaction,
    required HttpConfig httpConfig,
  }) async {
    try {
      late Address? address;
      late ImportedAddress? importedAddress;

      // Fetch UTXOs
      final (utxos, cachedTxHashes) = await utxoRepository
          .getUnspentForAddress(source, httpConfig, excludeCached: true);
      final Map<String, Utxo> utxoMap = {
        for (var e in utxos) "${e.txid}:${e.vout}": e
      };

      // Fetch Address, Account, and Wallet
      address = await addressRepository.getAddress(source);
      if (address == null) {
        importedAddress =
            await importedAddressRepository.getImportedAddress(source);
      }

      if (address == null && importedAddress == null) {
        throw SignAndBroadcastTransactionException('Address not found.');
      }

      late String addressPrivKey;
      if (address != null) {
        addressPrivKey =
            await _getAddressPrivKeyForAddress(address, decryptionStrategy);
      } else {
        addressPrivKey = await _getAddressPrivKeyForImportedAddress(
            importedAddress!, decryptionStrategy, httpConfig.network);
      }

      // Sign Transaction
      final txHex = await transactionService.signTransaction(
          rawtransaction, addressPrivKey, source, utxoMap, httpConfig);

      // Broadcast Transaction
      try {
        final txHash = await bitcoindService.sendrawtransaction(txHex, httpConfig);
        await onSuccess(txHex, txHash);
      } catch (e) {
        final String errorMessage = 'Failed to broadcast the transaction: $e';
        throw SignAndBroadcastTransactionException(errorMessage);
      }
    } on SignAndBroadcastTransactionException catch (e) {
      onError(e.message);
    } on TransactionServiceException catch (e) {
      onError(e.message);
    } catch (e) {
      onError('An unexpected error occurred.');
    }
  }

  // this refers to address that is part of actual wallet
  Future<String> _getAddressPrivKeyForAddress(
      Address address, DecryptionStrategy decryptionStrategy) async {
    final account =
        await accountRepository.getAccountByUuid(address.accountUuid);
    if (account == null) {
      throw SignAndBroadcastTransactionException('Account not found.');
    }

    final wallet = await walletRepository.getWallet(account.walletUuid);

    // Decrypt Root Private Key
    String decryptedRootPrivKey;

    try {
      decryptedRootPrivKey = switch (decryptionStrategy) {
        Password(password: var password) =>
          await encryptionService.decrypt(wallet!.encryptedPrivKey, password),
        InMemoryKey() => await encryptionService.decryptWithKey(
            wallet!.encryptedPrivKey, (await inMemoryKeyRepository.get())!)
      };
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

    return addressPrivKey;
  }

  Future<String> _getAddressPrivKeyForImportedAddress(
      ImportedAddress importedAddress,
      DecryptionStrategy decryptionStrategy,
      Network network) async {
    late String decryptedAddressWif;
    try {
      Future<String?> getKey() async {
        final maybeKey =
            (await inMemoryKeyRepository.getMap())[importedAddress.address];

        return maybeKey;
      }

      decryptedAddressWif = switch (decryptionStrategy) {
        Password(password: var password) => await encryptionService.decrypt(
            importedAddress.encryptedWif, password),
        InMemoryKey() => await encryptionService.decryptWithKey(
            importedAddress.encryptedWif, (await getKey())!)
      };
    } catch (e) {
      throw SignAndBroadcastTransactionException('Incorrect password.');
    }

    final addressPrivKey =
        await importedAddressService.getAddressPrivateKeyFromWIF(
            wif: decryptedAddressWif, network: network);

    return addressPrivKey;
  }
}
