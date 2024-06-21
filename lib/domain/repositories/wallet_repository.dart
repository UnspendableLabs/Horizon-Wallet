import 'package:horizon/domain/entities/wallet.dart' as entity;

abstract class WalletRepository {
  Future<entity.Wallet?> getWallet(String uuid);
  Future<void> insert(entity.Wallet wallet);
  Future<entity.Wallet?> getCurrentWallet();
  Future<void> deleteWallet(entity.Wallet wallet);
  Future<void> deleteAllWallets();
}
