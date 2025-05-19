import "package:get_it/get_it.dart";
import "package:fpdart/fpdart.dart";

import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/services/seed_service.dart';

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

class SignAndBroadcastTransactionUseCase<R extends ComposeResponse> {
  final UtxoRepository _utxoRepository;
  final EncryptionService _encryptionService;
  final AddressService _addressService;
  final TransactionService _transactionService;
  final BitcoindService _bitcoindService;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final SeedService _seedService;
  final WalletConfigRepository _walletConfigRepository;

  SignAndBroadcastTransactionUseCase({
    InMemoryKeyRepository? inMemoryKeyRepository,
    UtxoRepository? utxoRepository,
    EncryptionService? encryptionService,
    AddressService? addressService,
    TransactionService? transactionService,
    BitcoindService? bitcoindService,
    SeedService? seedService,
    WalletConfigRepository? walletConfigRepository,
  })  : _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
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
      String pk = switch (source.derivation) {
        Bip32Path(value: var value) => await $(_walletConfigRepository
            .getCurrentT((_) => "invariant: could not read wallet config")
            .flatMap((walletConfig) => _seedService
                .getForWalletConfigT(
                    walletConfig: walletConfig,
                    decryptionStrategy: decryptionStrategy,
                    onError: (_) => "invairant: could not derive seed")
                .flatMap((seed) => _addressService.deriveAddressPrivateKeyWIPT(
                      path: Bip32Path(value: value),
                      seed: seed,
                      network: httpConfig.network,
                    )))),
        WIF(value: var value) => await $(switch (decryptionStrategy) {
            Password(password: var password) => _encryptionService.decryptT(
                data: value,
                password: password,
                onError: (_, __) => "Invalid password"),
            InMemoryKey() => _inMemoryKeyRepository
                .getMapT(
                    onError: (_, __) =>
                        "invariant: failed to read in memory key map")
                .flatMap((map) => TaskEither.fromOption(
                    Option.fromNullable(map[source.address]),
                    () =>
                        "invariant: decryption key not found for address: ${source.address}"))
                .flatMap((decryptionKey) => _encryptionService.decryptWithKeyT(
                    data: value,
                    key: decryptionKey,
                    onError: (_, __) =>
                        "failed to decrypt wif for address: ${source.address}")),
          })
      };

      final utxoMap = await $(_utxoRepository.getUTXOMapForAddressT(
          address: source, httpConfig: httpConfig));

      final signedHex = await $(_transactionService.signTransactionT(
          unsignedTransaction: rawtransaction,
          privateKey: pk,
          sourceAddress: source.address,
          utxoMap: utxoMap,
          httpConfig: httpConfig,
          onError: (_) => "Failed to sign transaction"));

      final hash = await $(_bitcoindService.sendrawtransactionT(
          signedHex: signedHex,
          httpConfig: httpConfig,
          onError: (err, _) => err.toString()));

      return (signedHex, hash);
    });

    final result = await task.run();

    result.fold((msg) => onError(msg),
        (success) => {onSuccess(success.$1, success.$2)});
  }
}
