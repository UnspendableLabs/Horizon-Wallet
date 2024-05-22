import 'package:uniparty/domain/entities/wallet.dart' as entity;

abstract class WalletRepository {
  // Future<AccountEntity> getAccount();
  Future<void> insert(entity.Wallet wallet);
  // Future<void> deleteAccount();
}
