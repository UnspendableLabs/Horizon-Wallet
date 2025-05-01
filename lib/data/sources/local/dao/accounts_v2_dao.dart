import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/accounts_v2_table.dart';

part 'accounts_v2_dao.g.dart';

@DriftAccessor(tables: [AccountsV2])
class AccountsV2Dao extends DatabaseAccessor<DB> with _$AccountsV2DaoMixin {
  AccountsV2Dao(super.db);

  Future<List<AccountsV2Data>> getAll() => select(accountsV2).get();

  Future<void> insert(Insertable<AccountsV2Data> account) =>
      into(accountsV2).insert(account);

  Future<void> deleteAll() => delete(accountsV2).go();
}
