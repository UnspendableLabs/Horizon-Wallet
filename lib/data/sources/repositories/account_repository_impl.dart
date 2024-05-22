import "package:uniparty/data/sources/local/dao/account_dao.dart";
import "package:uniparty/data/sources/local/db.dart" as local;
import "package:uniparty/domain/entities/account.dart" as entity;
import "package:uniparty/domain/repositories/account_repository.dart";

class AccountRepositoryImpl implements AccountRepository {
  final local.DB _db;
  final AccountDao _accountDao;

  AccountRepositoryImpl(this._db) : _accountDao = AccountDao(_db);

  @override
  Future<void> insert(entity.Account accountEntity) async {
    await _accountDao
        .insertAccount(local.Account(uuid: accountEntity.uuid, defaultWalletUuid: accountEntity.defaultWalletUUID));
  }

  @override
  Future<entity.Account?> getAccount(String uuid) async {
    local.Account? accountLocal = await _accountDao.getAccountByUuid(uuid);
    if (accountLocal == null) {
      return null;
    }
    print('accountLocal: $accountLocal');
    return entity.Account(uuid: accountLocal.uuid, defaultWalletUUID: accountLocal.defaultWalletUuid);
  }
}
