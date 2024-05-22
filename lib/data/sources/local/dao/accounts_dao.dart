import 'package:drift/drift.dart';
import 'package:uniparty/common/uuid.dart';
import 'package:uniparty/data/sources/local/db.dart';
import 'package:uniparty/data/sources/local/tables/accounts_table.dart';
import 'package:uniparty/data/models/account.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<DB> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Future<List<AccountModel>> getAllAccounts() => select(accounts).get();
  Future<AccountModel?> getAccountByUuid(String uuid) => (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).getSingle();

  Stream<AccountModel?> watchAccountByUuid(String uuid) =>
      (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).watchSingle();
  Future<int> insertAccount(AccountModel account) {
    if (account.uuid.isEmpty) {
      account = account.copyWith(uuid: uuid.v4());
    }
    return into(accounts).insert(account);
  }

  Future<bool> updateAccount(Insertable<AccountModel> account) => update(accounts).replace(account);
  Future<int> deleteAccount(Insertable<AccountModel> account) => delete(accounts).delete(account);
}
