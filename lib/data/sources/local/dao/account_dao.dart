import 'package:drift/drift.dart';
import 'package:uniparty/common/uuid.dart';
import 'package:uniparty/data/sources/local/db.dart';
import 'package:uniparty/data/sources/local/tables/account_table.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<DB> with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Future<Account?> getAccountByUuid(String uuid) => (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).getSingle();

  Stream<Account?> watchAccountByUuid(String uuid) =>
      (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).watchSingle();
  Future<int> insertAccount(Account account) {
    if (account.uuid.isEmpty) {
      account = account.copyWith(uuid: uuid.v4());
    }
    return into(accounts).insert(account);
  }

  Future<bool> updateAccount(Insertable<Account> account) => update(accounts).replace(account);
  Future<int> deleteAccount(Insertable<Account> account) => delete(accounts).delete(account);
}
