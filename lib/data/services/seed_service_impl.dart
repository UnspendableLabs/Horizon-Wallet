import "package:fpdart/fpdart.dart";
import 'package:convert/convert.dart';
import 'dart:js_interop';
import "package:get_it/get_it.dart";
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/mnemonicjs.dart';

class SeedServiceImpl implements SeedService {
  final MnemonicRepository _mnemonicRepository;
  final EncryptionService _encryptionService;
  final InMemoryKeyRepository _inMemoryKeyRepository;

  SeedServiceImpl({
    InMemoryKeyRepository? inMemoryKeyRepository,
    EncryptionService? encryptionService,
    MnemonicRepository? mnemonicRepository,
  })  : _mnemonicRepository = GetIt.I<MnemonicRepository>(),
        _encryptionService = GetIt.I<EncryptionService>(),
        _inMemoryKeyRepository = GetIt.I<InMemoryKeyRepository>();

  @override
  Future<Seed> getForWalletConfig(
      {required WalletConfig walletConfig,
      required DecryptionStrategy decryptionStrategy}) async {
    final task = TaskEither<String, Seed>.Do(($) async {
      final encryptedMnemonic = await $(_mnemonicRepository
          .getT(onError: (_, __) => "invariant: error reading mnemonic")
          .flatMap((mnemonic) => TaskEither.fromOption(
              mnemonic, () => "invariant: mnemonic is null")));

      // end

      String mnemonic = switch (decryptionStrategy) {
        Password(password: final password) => await $(
            _encryptionService.decryptT(
                data: encryptedMnemonic,
                password: password,
                onError: (_, __) => "Invalid password")),
        InMemoryKey() => await $(_inMemoryKeyRepository
              .getMnemonicKeyT(
                onError: (_, __) => "invariant: error getting in-memory key",
              )
              .flatMap((maybeKey) => TaskEither.fromOption(
                    maybeKey,
                    () =>
                        "invariant: error getting in-memory key, key not found",
                  ))
              .flatMap((key) {
            return _encryptionService.decryptWithKeyT(
                data: encryptedMnemonic,
                key: key,
                onError: (_, __) =>
                    "invariant: error decrypting mnemonic with in-memory key");
          }))
      };

      final seed = await $(_getSeed(
          derivation: walletConfig.seedDerivation, mnemonic: mnemonic));

      return seed;
    });

    final result = await task.run();

    return result.getOrElse(
      (_) => throw Exception("Failed to get seed"),
    );
  }

  TaskEither<String, Seed> _getSeed(
          {required SeedDerivation derivation, required String mnemonic}) =>
      TaskEither.tryCatch(
          () => _seed(derivation: derivation, mnemonic: mnemonic),
          (e, __) => e.toString());

  Future<Seed> _seed(
      {required SeedDerivation derivation, required String mnemonic}) async {
    return switch (derivation) {
      SeedDerivation.bip39MnemonicToSeed => Seed.fromHex(
          hex.encode((await bip39.mnemonicToSeed(mnemonic).toDart).toDart)),
      SeedDerivation.bip39MnemonicToEntropy =>
        Seed.fromHex((bip39.mnemonicToEntropy(mnemonic))),
      SeedDerivation.mnemonicJSToHex => Seed.fromHex(
          Mnemonic(mnemonic.split(" ").map((el) => el.toJS).toList().toJS)
              .toHex())
    };
  }
}
