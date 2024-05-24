import 'package:uniparty/domain/entities/wallet.dart' as entity;

abstract class WalletRepository {
  Future<entity.Wallet?> getWalletByUuid(String uuid);
  Future<void> insert(entity.Wallet wallet);
}
