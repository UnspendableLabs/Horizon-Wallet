import 'package:drift/drift.dart';
import 'package:horizon/data/models/account.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<DB> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Future<List<AccountModel>> getAllAccounts() => select(accounts).get();
  Future<AccountModel?> getAccountByUuid(String uuid) =>
      (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).getSingle();

  // TODO: get the actual current account
  Future<AccountModel?> getCurrentAccount() => select(accounts).getSingle();

  Stream<AccountModel?> watchAccountByUuid(String uuid) =>
      (select(accounts)..where((tbl) => tbl.uuid.equals(uuid))).watchSingle();
  Future<int> insertAccount(AccountModel account) {
    return into(accounts).insert(account);
  }

  Future<bool> updateAccount(Insertable<AccountModel> account) => update(accounts).replace(account);
  Future<int> deleteAccount(Insertable<AccountModel> account) => delete(accounts).delete(account);
}
