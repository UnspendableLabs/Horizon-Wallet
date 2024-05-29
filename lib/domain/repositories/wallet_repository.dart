import 'package:horizon/domain/entities/wallet.dart' as entity;

abstract class WalletRepository {
  Future<entity.Wallet?> getWalletByUuid(String uuid);
  Future<List<entity.Wallet>> getWalletsByAccountUuid(String accountUuid);
  Future<void> insert(entity.Wallet wallet);
  Future<void> deleteWallet(entity.Wallet wallet);
  Future<void> deleteAllWallets();
}
