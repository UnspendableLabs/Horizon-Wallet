import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/wallet_configs_table.dart';
import "package:horizon/domain/entities/network.dart";
import 'package:horizon/domain/entities/seed_derivation.dart';

part 'wallet_configs_dao.g.dart';

@DriftAccessor(tables: [WalletConfigs])
class WalletConfigsDao extends DatabaseAccessor<DB>
    with _$WalletConfigsDaoMixin {
  WalletConfigsDao(super.db);

  Future<WalletConfig?> getByID(String uuid) async {
    return (select(walletConfigs)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<List<WalletConfig>> getAll() async {
    return select(walletConfigs).get();
  }

  Future<int> create(WalletConfig config) async {
    return into(walletConfigs).insert(config);
  }

  Future<bool> update_(WalletConfig config) async {
    return update(walletConfigs).replace(config);
  }

  Future<WalletConfig?> getByPrimaryKey(
      {required String basePath,
      required Network network,
      required SeedDerivation seedDerivation}) async {
    return (select(walletConfigs)
          ..where((tbl) =>
              tbl.basePath.equals(basePath) &
              tbl.network.equals(network.name) &
              tbl.seedDerivation.equals(seedDerivation.name)))
        .getSingleOrNull();
  }
}
