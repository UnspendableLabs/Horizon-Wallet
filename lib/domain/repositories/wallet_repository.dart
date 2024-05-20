import "package:uniparty/domain/entities/wallet_entity.dart";

abstract class WalletRepository {
  // Future<AccountEntity> getAccount();
  Future<void> insert(WalletRepository wallet);
  // Future<void> deleteAccount();
}
