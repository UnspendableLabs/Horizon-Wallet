import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
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
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/services/seed_service.dart';
import "package:get_it/get_it.dart";
import "package:fpdart/fpdart.dart";

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
  final ImportedAddressRepository importedAddressRepository;
  final UtxoRepository utxoRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final TransactionLocalRepository transactionLocalRepository;
  final ImportedAddressService importedAddressService;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final SeedService _seedService;
  final WalletConfigRepository _walletConfigRepository;

  SignAndBroadcastTransactionUseCase({
    required this.inMemoryKeyRepository,
    required this.importedAddressRepository,
    required this.utxoRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionService,
    required this.bitcoindService,
    required this.transactionLocalRepository,
    required this.importedAddressService,
    SeedService? seedService,
    WalletConfigRepository? walletConfigRepository,
  })  : _seedService = seedService ?? GetIt.I<SeedService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>();

  Future<void> call({
    required AddressV2 source,
    required DecryptionStrategy decryptionStrategy,
    required Function(String, String) onSuccess,
    required Function(String) onError,
    required String rawtransaction,
    required HttpConfig httpConfig,
  }) async {
    final task = TaskEither<String, (String hex, String hash)>.Do(($) async {
      final utxoMap = await $(_getUTXOMap(
        source: source,
        httpConfig: httpConfig,
      ));

      final walletConfig = await $(_getWalletConfig());

      final seed = await $(_seedService.getForWalletConfig(
          walletConfig: walletConfig, decryptionStrategy: decryptionStrategy));

      final pk = await $(_getAddressPrivateKey(
          address: source, seed: seed, network: httpConfig.network));

      final signedHex = await $(_signTransaction(
          pk: pk,
          unsigned: rawtransaction,
          source: source,
          utxoMap: utxoMap,
          httpConfig: httpConfig));

      final hash = await $(_broadcastTransaction(
          rawtransaction: signedHex, httpConfig: httpConfig));

      return (signedHex, hash);
    });

    final result = await task.run();

    result.fold((msg) => onError(msg),
        (success) => {onSuccess(success.$1, success.$2)});
  }

  // this refers to address that is part of actual wallet
  Future<String> _getAddressPrivKeyForAddress(
      Address address, DecryptionStrategy decryptionStrategy) async {
    throw UnimplementedError(
        'SignAndBroadcastTransactionUseCase is not implemented');
    // final account =
    //     await accountRepository.getAccountByUuid(address.accountUuid);
    // if (account == null) {
    //   throw SignAndBroadcastTransactionException('Account not found.');
    // }
    //
    // final wallet = await walletRepository.getWallet(account.walletUuid);
    //
    // // Decrypt Root Private Key
    // String decryptedRootPrivKey;
    //
    // try {
    //   decryptedRootPrivKey = switch (decryptionStrategy) {
    //     Password(password: var password) =>
    //       await encryptionService.decrypt(wallet!.encryptedPrivKey, password),
    //     InMemoryKey() => await encryptionService.decryptWithKey(
    //         wallet!.encryptedPrivKey, (await inMemoryKeyRepository.get())!)
    //   };
    // } catch (e) {
    //   throw SignAndBroadcastTransactionException('Incorrect password.');
    // }
    //
    // // Derive Address Private Key
    // final addressPrivKey = await addressService.deriveAddressPrivateKey(
    //   rootPrivKey: decryptedRootPrivKey,
    //   chainCodeHex: wallet.chainCodeHex,
    //   purpose: account.purpose,
    //   coin: account.coinType,
    //   account: account.accountIndex,
    //   change: '0',
    //   index: address.index,
    //   importFormat: account.importFormat,
    // );
    //
    // return addressPrivKey;
  }

  Future<String> _getAddressPrivKeyForImportedAddress(
      ImportedAddress importedAddress,
      DecryptionStrategy decryptionStrategy,
      Network network) async {
    throw UnimplementedError(
        'SignAndBroadcastTransactionUseCase is not implemented');
    //   late String decryptedAddressWif;
    //   try {
    //     Future<String?> getKey() async {
    //       final maybeKey =
    //           (await inMemoryKeyRepository.getMap())[importedAddress.address];
    //
    //       return maybeKey;
    //     }
    //
    //     decryptedAddressWif = switch (decryptionStrategy) {
    //       Password(password: var password) => await encryptionService.decrypt(
    //           importedAddress.encryptedWif, password),
    //       InMemoryKey() => await encryptionService.decryptWithKey(
    //           importedAddress.encryptedWif, (await getKey())!)
    //     };
    //   } catch (e) {
    //     throw SignAndBroadcastTransactionException('Incorrect password.');
    //   }
    //
    //   final addressPrivKey =
    //       await importedAddressService.getAddressPrivateKeyFromWIF(
    //           wif: decryptedAddressWif, network: network);
    //
    //   return addressPrivKey;
    // }
  }

  TaskEither<String, WalletConfig> _getWalletConfig() {
    return TaskEither.tryCatch(
      () => _walletConfigRepository.getCurrent(),
      (_, __) => "Failed to get wallet config",
    );
  }

  TaskEither<String, Map<String, Utxo>> _getUTXOMap(
      {required AddressV2 source, required HttpConfig httpConfig}) {
    return TaskEither.tryCatch(() async {
      final (utxos, cachedTxHashes) = await utxoRepository.getUnspentForAddress(
          source.address, httpConfig,
          excludeCached: true);
      final Map<String, Utxo> utxoMap = {
        for (var e in utxos) "${e.txid}:${e.vout}": e
      };

      return utxoMap;
    }, (_, __) => "Failed to get UTXO map for address ${source.address}");
  }

  TaskEither<String, String> _signTransaction({
    required String unsigned,
    required String pk,
    required AddressV2 source,
    required Map<String, Utxo> utxoMap,
    required HttpConfig httpConfig,
  }) {
    return TaskEither.tryCatch(
        () => transactionService.signTransaction(
            unsigned, pk, source.address, utxoMap, httpConfig),
        (_, __) => "Failed to sign transaction");
  }

  TaskEither<String, String> _getAddressPrivateKey(
      {required AddressV2 address,
      required Seed seed,
      required Network network}) {
    return TaskEither.tryCatch(
      () => addressService.deriveAddressPrivateKeyWIP(
          address: address, seed: seed, network: network),
      (_, __) => "Failed to get address private key",
    );
  }

  TaskEither<String, String> _broadcastTransaction(
      {required String rawtransaction, required HttpConfig httpConfig}) {
    return TaskEither.tryCatch(
      () => bitcoindService.sendrawtransaction(rawtransaction, httpConfig),
      (_, __) => "Failed to broadcast transaction",
    );
  }

  //   final txHex = awit transactionService.signTransaction(
  //       rawtransaction, addressPrivKey, source, utxoMap, httpConfig);
}
