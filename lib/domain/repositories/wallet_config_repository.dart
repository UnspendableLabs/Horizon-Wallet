import "package:horizon/domain/entities/wallet_config.dart";
import "package:horizon/domain/entities/network.dart";
import "package:horizon/domain/entities/seed_derivation.dart";
import "package:fpdart/fpdart.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
  Future<WalletConfig> getCurrent();
  Future<Option<WalletConfig>> getByID({required String id});
  Future<int> create(WalletConfig walletConfig);
  Future<bool> update(WalletConfig walletConfig);
  // Future<int> initialize();
  Future<WalletConfig> findOrCreate(
      {required String basePath,
      required Network network,
      SeedDerivation? seedDerivation});
}
