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
      (select(accounts)..where((tbl) => tbl.uuid.equals(uuid)))
          .getSingleOrNull();
  Future<List<AccountModel>> getAccountsByWalletUuid(String walletUuid) =>
      (select(accounts)..where((tbl) => tbl.walletUuid.equals(walletUuid)))
          .get();

  Future<void> insertAccount(Insertable<AccountModel> account) =>
      into(accounts).insert(account);
  Future<void> updateAccount(Insertable<AccountModel> account) =>
      update(accounts).replace(account);
  Future<void> deleteAccount(Insertable<AccountModel> account) =>
      delete(accounts).delete(account);

  Future<int> deleteAllAccounts() {
    return delete(accounts).go();
  }

  Future<List<AccountModel>> findAccountsByWalletUuid(String walletUuid) =>
      (select(accounts)..where((tbl) => tbl.walletUuid.equals(walletUuid)))
          .get();
}
