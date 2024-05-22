import 'package:drift/drift.dart';

import 'package:uniparty/common/uuid.dart';

import "package:uniparty/data/sources/local/db.dart" as local;
import "package:uniparty/data/sources/local/dao/wallets_dao.dart";
import "package:uniparty/data/models/wallet.dart";
import "package:uniparty/domain/entities/wallet.dart" as entity;
import "package:uniparty/domain/entities/wallet.dart";
import "package:uniparty/domain/entities/wallet.dart";
import "package:uniparty/domain/repositories/wallet_repository.dart";

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


  // @override
  // Future<entity.Wallet?> getWallet(String uuid) async {
  //   throw UnimplementedError();
  // }
}
