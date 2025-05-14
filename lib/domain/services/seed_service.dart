import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

abstract class SeedService {
  TaskEither<String, Seed> getForWalletConfig(
      {required WalletConfig walletConfig,
      required DecryptionStrategy decryptionStrategy});
}
