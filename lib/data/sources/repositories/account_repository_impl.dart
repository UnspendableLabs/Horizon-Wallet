import 'package:drift/drift.dart';

import 'package:uniparty/common/uuid.dart';

import "package:uniparty/data/sources/local/dao/accounts_dao.dart";
import "package:uniparty/data/sources/local/db.dart" as local;
import "package:uniparty/domain/entities/account.dart" as entity;
import "package:uniparty/domain/entities/wallet.dart";
import "package:uniparty/domain/entities/address.dart";
import "package:uniparty/domain/repositories/account_repository.dart";

class AccountRepositoryImpl implements AccountRepository {
  final local.DB _db;
  final AccountsDao _accountDao;

  AccountRepositoryImpl(this._db) : _accountDao = AccountsDao(_db);

  @override
  Future<void> insert(entity.Account account) async {
    await _accountDao
        .insertAccount(local.Account(uuid: account.uuid ?? uuid.v4()));
  }

  @override
  Future<entity.Account?> getAccount(String uuid) async {
    local.Account? accountLocal = await _accountDao.getAccountByUuid(uuid);
    if (accountLocal == null) {
      return null;
    }
    print('accountLocal: $accountLocal');
    return entity.Account(
      uuid: accountLocal.uuid,
    );
  }

  // @override
  // Future<void> initializeWithWalletAndAddresses(
  //     Wallet wallet, List<Address> addresses) async {
  //
  //     await transaction(() async {
  //
  //
  //         await _accountDao.insertAccount(local.Account(uuid: uuid.v4()));
  //
  //
  //     });
  //     
  //           
  //     
  //
  //
  //
  //   }
}
