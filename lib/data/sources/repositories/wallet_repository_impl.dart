import 'package:horizon/common/uuid.dart';
import "package:horizon/data/models/wallet.dart";
import "package:horizon/data/sources/local/dao/wallets_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet.dart" as entity;
import "package:horizon/domain/repositories/wallet_repository.dart";

class WalletRepositoryImpl implements WalletRepository {
  final local.DB _db;
  final WalletsDao _walletDao;

  WalletRepositoryImpl(this._db) : _walletDao = WalletsDao(_db);

  @override
  Future<void> insert(entity.Wallet wallet) async {
    await _walletDao.insertWallet(WalletModel(
      uuid: wallet.uuid ?? uuid.v4(),
      name: wallet.name,
      wif: wallet.wif,
    ));
  }

  @override
  Future<entity.Wallet?> getWallet(String uuid) async {
    WalletModel? walletLocal = await _walletDao.getWalletByUuid(uuid);
    if (walletLocal == null) {
      return null;
    }
    print('walletLocal: $walletLocal');
    return entity.Wallet(
      uuid: walletLocal.uuid,
      name: walletLocal.name,
      wif: walletLocal.wif,
    );
  }

  @override
  Future<entity.Wallet?> getCurrentWallet() async {
    // TODO: how to mark current wallet?
    WalletModel? wallet = await _walletDao.getCurrentWallet();
    return entity.Wallet(
      uuid: wallet!.uuid,
      name: wallet!.name,
      wif: wallet!.wif,
    );
    // return null;
  }

  @override
  Future<void> deleteWallet(entity.Wallet wallet) async {
    await _walletDao.deleteWallet(WalletModel(uuid: wallet.uuid!, name: wallet.name, wif: wallet.wif));
  }

  @override
  Future<void> deleteAllWallets() async {
    await _walletDao.deleteAllWallets();
  }
}
