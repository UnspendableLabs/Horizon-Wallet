import "package:horizon/data/sources/local/dao/wallet_configs_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet_config.dart" as entity;
import "package:horizon/domain/repositories/wallet_config_repository.dart";

class WalletConfigRepositoryImpl implements WalletConfigRepository {
  // ignore: unused_field
  final local.DB _db;
  final WalletConfigsDao _walletConfigsDao;

  final defaultMainnet = entity.WalletConfig(
      network: "mainnet",
      basePath: "84'/0'/",
      accountIndexStart: 0,
      accountIndexEnd: 0);

  final defaultTestnet4 = entity.WalletConfig(
      network: "testnet4",
      basePath: "84'/1'/",
      accountIndexStart: 0,
      accountIndexEnd: 0);

  WalletConfigRepositoryImpl(this._db)
      : _walletConfigsDao = WalletConfigsDao(_db);

  @override
  Future<List<entity.WalletConfig>> getAll() async {
    final configs = await _walletConfigsDao.getAll();

    return [defaultMainnet, defaultTestnet4] +
        configs
            .map((config) => entity.WalletConfig(
                network: config.network,
                basePath: config.basePath,
                accountIndexStart: config.accountIndexStart,
                accountIndexEnd: config.accountIndexEnd))
            .toList();
  }
}
