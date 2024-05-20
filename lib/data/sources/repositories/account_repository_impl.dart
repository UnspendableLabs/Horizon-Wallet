import "package:uniparty/data/sources/local/db.dart";
import "package:uniparty/data/models/account.dart";
import "package:uniparty/domain/repositories/account_repository.dart";
import "package:uniparty/domain/entities/account_entity.dart";

class AccountRepositoryImpl implements AccountRepository {
  final DB _db;

  AccountRepositoryImpl(this._db);

  @override
  Future<void> insert(AccountEntity account) {
    return _db.accountDao.insertAccount(Account.fromEntity(account));
  }
}
