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
    WalletModel wallet_ = WalletModel(
      uuid: wallet.uuid ?? uuid.v4(),
      accountUuid: wallet.accountUuid!,
      publicKey: wallet.publicKey,
      wif: wallet.wif,
    );

    await _walletDao.insertWallet(wallet_);
  }

  @override
  Future<entity.Wallet?> getWalletByUuid(String uuid) async {
    WalletModel? wallet = await _walletDao.getWalletByUuid(uuid);
    return wallet != null
        ? entity.Wallet(uuid: wallet.uuid, accountUuid: wallet.accountUuid, publicKey: wallet.publicKey, wif: wallet.wif)
        : null;
  }
}
