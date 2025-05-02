import "package:horizon/domain/entities/wallet_config.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
}
