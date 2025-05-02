import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/wallet_configs_table.dart';

part 'wallet_configs_dao.g.dart';

@DriftAccessor(tables: [WalletConfigs])
class WalletConfigsDao extends DatabaseAccessor<DB>
    with _$WalletConfigsDaoMixin {
  WalletConfigsDao(super.db);

  Future<List<WalletConfig>> getAll() async {
    return select(walletConfigs).get();
  }

  Future<int> create(WalletConfig config) async {
    return into(walletConfigs).insert(config);
  }
  
  Future<bool> update_(WalletConfig config) async {
    return update(walletConfigs).replace(config);
  }
}
