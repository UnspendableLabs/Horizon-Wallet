import "package:horizon/domain/entities/wallet_config.dart";
import "package:horizon/domain/entities/network.dart";
import "package:horizon/domain/entities/base_path.dart";
import "package:horizon/domain/entities/seed_derivation.dart";
import "package:fpdart/fpdart.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
  Future<WalletConfig> getCurrent();
  Future<Option<WalletConfig>> getByID({required String id});
  Future<int> create(WalletConfig walletConfig);
  Future<bool> update(WalletConfig walletConfig);
  Future<WalletConfig> createOrUpdate(WalletConfig config);
  Future<WalletConfig> findOrCreate(
      {required BasePath basePath,
      required Network network,
      required SeedDerivation seedDerivation});
}
