import "package:flutter/foundation.dart";
import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/usecases/usecase.dart';
import 'package:horizon/extensions.dart';

export 'package:horizon/domain/entities/decryption_strategy.dart';
export 'package:horizon/domain/usecases/usecase.dart';

class BroadcastResponse {
  final String hex;
  final String hash;

  const BroadcastResponse({
    required this.hex,
    required this.hash,
  });
}

class SignAndBroadcastTransactionParams {
  final AddressV2 source;
  final DecryptionStrategy decryptionStrategy;
  final String rawtransaction;
  final HttpConfig httpConfig;

  const SignAndBroadcastTransactionParams({
    required this.source,
    required this.decryptionStrategy,
    required this.rawtransaction,
    required this.httpConfig,
  });
}

class SignAndBroadcastTransactionUseCase
    implements
        UseCaseTE<BroadcastResponse, SignAndBroadcastTransactionParams,
            String> {
  final UtxoRepository _utxoRepository;
  final EncryptionService _encryptionService;
  final AddressService _addressService;
  final TransactionService _transactionService;
  final BitcoindService _bitcoindService;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final SeedService _seedService;
  final WalletConfigRepository _walletConfigRepository;
  final ErrorService _errorService;
  final ImportedAddressService _importedAddressService;

  SignAndBroadcastTransactionUseCase({
    InMemoryKeyRepository? inMemoryKeyRepository,
    UtxoRepository? utxoRepository,
    EncryptionService? encryptionService,
    AddressService? addressService,
    TransactionService? transactionService,
    BitcoindService? bitcoindService,
    SeedService? seedService,
    WalletConfigRepository? walletConfigRepository,
    ErrorService? errorService,
    ImportedAddressService? importedAddressService,
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
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>(),
        _importedAddressService =
            importedAddressService ?? GetIt.I<ImportedAddressService>();

  @override
  TaskEither<String, BroadcastResponse> call(
      SignAndBroadcastTransactionParams params) {
    return TaskEither<String, BroadcastResponse>.Do(($) async {
      String pk = switch (params.source.derivation) {
        Bip32Path(value: var value) => await $(_walletConfigRepository
            .getCurrentT((_) => "invariant: could not read wallet config")
            .flatMap((walletConfig) => _seedService
                .getForWalletConfigT(
                    walletConfig: walletConfig,
                    decryptionStrategy: params.decryptionStrategy,
                    onError: (_) => "invariant: could not derive seed")
                .flatMap((seed) => _addressService.deriveAddressPrivateKeyWIPT(
                      path: Bip32Path(value: value),
                      seed: seed,
                      network: params.httpConfig.network,
                    )))),
        WIF(value: var value) => await $(switch (params.decryptionStrategy) {
            Password(password: var password) => _encryptionService.decryptT(
                data: value,
                password: password,
                onError: (_, __) => "Invalid password"),
            InMemoryKey() => _inMemoryKeyRepository
                .getMapT(
                    onError: (_, __) =>
                        "invariant: failed to read in memory key map")
                .flatMap((map) {
                  return TaskEither.fromOption(
                      Option.fromNullable(map[value]),
                      () =>
                          "invariant: decryption key not found for address: ${params.source.address}");
                })
                .flatMap((decryptionKey) => _encryptionService.decryptWithKeyT(
                    data: value,
                    key: decryptionKey,
                    onError: (_, __) =>
                        "failed to decrypt wif for address: ${params.source.address}"))
                .flatMap((wif) =>
                    _importedAddressService.getAddressPrivateKeyFromWIFT(
                        wif: wif,
                        network: params.httpConfig.network,
                        onError: (_, __) =>
                            "Failed to get private key from WIF for address: ${params.source.address}"))
          })
      };

      final utxoMap = await $(handleNetworkCall(() async {
        return await _utxoRepository.getUTXOMapForAddress(
            params.source, params.httpConfig);
      }).mapLeft((error) => error.toDebugString()));

      final signedHex = await $(_transactionService.signTransactionT(
          unsignedTransaction: params.rawtransaction,
          privateKey: pk,
          sourceAddress: params.source.address,
          utxoMap: utxoMap,
          httpConfig: params.httpConfig,
          onError: (error) =>
              kDebugMode ? error.toString() : "Failed to sign transaction"));

      final hash = await $(handleNetworkCall(() async {
        return await _bitcoindService.sendrawtransaction(
            signedHex, params.httpConfig);
      }).mapLeft((error) => error.toDebugString()));

      return BroadcastResponse(
        hex: signedHex,
        hash: hash,
      );
    }).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to sign and broadcast transaction",
        context: {
          "error": error,
        },
      );
    });
  }
}
