import "package:horizon/domain/entities/wallet_config.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
  Future<int> create(WalletConfig walletConfig);
  Future<bool> update(WalletConfig walletConfig);
}
