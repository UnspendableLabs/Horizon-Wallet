import "package:horizon/domain/entities/wallet_config.dart";
import "package:fpdart/fpdart.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
  Future<Option<WalletConfig>> getByID({ required String  id });
  Future<int> create(WalletConfig walletConfig);
  Future<bool> update(WalletConfig walletConfig);
  Future<int> initialize();
}
