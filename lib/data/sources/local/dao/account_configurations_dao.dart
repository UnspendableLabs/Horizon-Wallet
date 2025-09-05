import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/account_configurations_table.dart';
import "package:horizon/domain/entities/network.dart";
import 'package:horizon/domain/entities/seed_derivation.dart';

part 'account_configurations_dao.g.dart';

@DriftAccessor(tables: [AccountConfigurations])
class AccountConfigurationsDao extends DatabaseAccessor<DB>
    with _$AccountConfigurationsDaoMixin {
  AccountConfigurationsDao(super.db);

  Future<AccountConfiguration?> getByWalletConfigAndAccountIndex(
      {required String walletUUID, required int index}) async {
    return (select(accountConfigurations)
          ..where((tbl) =>
              tbl.walletUUID.equals(walletUUID) & tbl.index.equals(index)))
        .getSingleOrNull();
  }

  Future<int> create(AccountConfiguration config) async {
    return into(accountConfigurations).insert(config);
  }

  Future<bool> update_(AccountConfiguration config) async {
    return update(accountConfigurations).replace(config);
  }
}
