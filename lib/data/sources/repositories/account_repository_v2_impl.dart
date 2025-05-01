import "package:horizon/common/constants.dart";
import 'package:uuid/uuid.dart';
import "package:horizon/data/sources/local/dao/accounts_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/account_v2_repository.dart";

class AccountV2RepositoryImpl implements AccountV2Repository {
  // ignore: unused_field
  final local.DB _db;
  final AccountsV2Dao _accountDao;

  AccountV2RepositoryImpl(this._db) : _accountDao = AccountsV2Dao(_db);

  @override
  Future<List<AccountV2>> getAll() async {
    final accounts = await _accountDao.getAll();
    return accounts
        .map((account) => AccountV2(uuid: account.uuid, index: account.index))
        .toList();
  }

  @override
  Future<void> insert(AccountV2 account) async {
    await _accountDao
        .insert(local.AccountsV2Data(uuid: account.uuid, index: account.index));
  }

  @override
  Future<void> deleteAll() async {
    await _accountDao.deleteAll();
  }
}
