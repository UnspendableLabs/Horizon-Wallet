import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

abstract class SeedService {
  Future<Seed> getForWalletConfig({
    required WalletConfig walletConfig,
    required DecryptionStrategy decryptionStrategy,
  });
}

extension SeedServiceX on SeedService {
  TaskEither<String, Seed> getForWalletConfigT({
    required WalletConfig walletConfig,
    required DecryptionStrategy decryptionStrategy,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => getForWalletConfig(
        walletConfig: walletConfig,
        decryptionStrategy: decryptionStrategy,
      ),
      (e, _) => onError(e),
    );
  }
}
