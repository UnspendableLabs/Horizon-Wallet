
import "package:uniparty/data/sources/local/db.dart";
import "package:uniparty/data/models/wallet.dart";
import "package:uniparty/domain/repositories/wallet_repository.dart";
import "package:uniparty/domain/entities/wallet_entity.dart";

class WalletRepositoryImpl implements WalletRepository {
  final DB _db;

  WalletRepositoryImpl(this._db);

  @override
  Future<void> insert(WalletEntity wallet) {
    return _db.walletDao.insertWallet(Wallet.fromEntity(wallet));
  }
}
