import "package:fpdart/fpdart.dart";
import 'package:convert/convert.dart';
import 'dart:js_interop';
import "package:get_it/get_it.dart";
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/mnemonicjs.dart';

class SeedServiceImpl implements SeedService {
  MnemonicRepository _mnemonicRepository;
  EncryptionService _encryptionService;
  InMemoryKeyRepository _inMemoryKeyRepository;

  SeedServiceImpl({
    InMemoryKeyRepository? inMemoryKeyRepository,
    EncryptionService? encryptionService,
    MnemonicRepository? mnemonicRepository,
  })  : _mnemonicRepository = GetIt.I<MnemonicRepository>(),
        _encryptionService = GetIt.I<EncryptionService>(),
        _inMemoryKeyRepository = GetIt.I<InMemoryKeyRepository>();

  @override
  TaskEither<String, Seed> getForWalletConfig(
      {required WalletConfig walletConfig}) {
    return TaskEither.Do(($) async {
      final encryptedMnemonic_ =
          await $(_mnemonicRepository.get().toTaskEither());

      final encryptedMnemonic = await $(
          TaskEither.fromOption(encryptedMnemonic_, () => "Missing mnemonic"));

      final inMemoryKey =
          await $(TaskEither.fromTask(_inMemoryKeyRepository.getMnemonicKey()));

      final key = await $(TaskEither<String, String>.fromOption(
          inMemoryKey, () => "Missing in-memory key"));

      final mnemonic =
          await $(_encryptionService.decryptWithKeyT(encryptedMnemonic, key));

      final seed = await $(_getSeed(
          derivation: walletConfig.seedDerivation, mnemonic: mnemonic));

      return seed;
    });
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
