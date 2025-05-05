import "package:horizon/data/sources/local/dao/wallet_configs_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet_config.dart" as entity;
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/common/uuid.dart";
import "package:fpdart/fpdart.dart";

class WalletConfigRepositoryImpl implements WalletConfigRepository {
  // ignore: unused_field
  final local.DB _db;
  final WalletConfigsDao _walletConfigsDao;

  WalletConfigRepositoryImpl(this._db)
      : _walletConfigsDao = WalletConfigsDao(_db);

  @override
  Future<int> initialize() async {
    return await _walletConfigsDao.create(local.WalletConfig(
        network: "mainnet",
        basePath: "84'/0'/",
        accountIndexStart: 0,
        accountIndexEnd: 0,
        uuid: uuid.v4()));
  }

  @override
  Future<Option<entity.WalletConfig>> getByID({required String id}) async {
    final config = await _walletConfigsDao.getByID(id);

    return Option.fromNullable(config).map(
      (config) => entity.WalletConfig(
        uuid: config.uuid,
        network: config.network,
        basePath: config.basePath,
        accountIndexStart: config.accountIndexStart,
        accountIndexEnd: config.accountIndexEnd,
      ),
    );
  }

  @override
  Future<List<entity.WalletConfig>> getAll() async {
    final configs = await _walletConfigsDao.getAll();

    return configs
        .map((config) => entity.WalletConfig(
            uuid: config.uuid,
            network: config.network,
            basePath: config.basePath,
            accountIndexStart: config.accountIndexStart,
            accountIndexEnd: config.accountIndexEnd))
        .toList();
  }

  @override
  Future<bool> update(entity.WalletConfig config) async {
    return await _walletConfigsDao.update_(local.WalletConfig(
        uuid: config.uuid,
        network: config.network,
        basePath: config.basePath,
        accountIndexStart: config.accountIndexStart,
        accountIndexEnd: config.accountIndexEnd));
  }

  @override
  Future<int> create(entity.WalletConfig config) async {
    return await _walletConfigsDao.create(local.WalletConfig(
        uuid: config.uuid,
        network: config.network,
        basePath: config.basePath,
        accountIndexStart: config.accountIndexStart,
        accountIndexEnd: config.accountIndexEnd));
  }
}
