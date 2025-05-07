import "package:horizon/data/sources/local/dao/wallet_configs_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet_config.dart" as entity;
import "package:horizon/domain/entities/seed_derivation.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/common/uuid.dart";
import "package:fpdart/fpdart.dart";
import "package:horizon/domain/entities/network.dart";
import 'package:get_it/get_it.dart';

import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/extensions.dart';

class WalletConfigRepositoryImpl implements WalletConfigRepository {
  // ignore: unused_field
  final local.DB _db;
  final WalletConfigsDao _walletConfigsDao;
  final SettingsRepository _settingsRepository;

  WalletConfigRepositoryImpl(
    this._db, [
    SettingsRepository? settingsRepository,
  ])  : _walletConfigsDao = WalletConfigsDao(_db),
        _settingsRepository =
            settingsRepository ?? GetIt.I<SettingsRepository>();

  @override
  Future<entity.WalletConfig> getCurrent() async {
    final network = _settingsRepository.network;
    final basePath = _settingsRepository.basePath;

    return findOrCreate(
      basePath: basePath.get(network),
      network: network,
    );
  }

  @override
  Future<Option<entity.WalletConfig>> getByID({required String id}) async {
    final config = await _walletConfigsDao.getByID(id);

    return Option.fromNullable(config).map(
      (config) => entity.WalletConfig(
        uuid: config.uuid,
        network: NetworkX.fromString(config.network)
            .getOrElse(() => Network.mainnet),
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
            network: NetworkX.fromString(config.network)
                .getOrElse(() => Network.mainnet),
            basePath: config.basePath,
            accountIndexStart: config.accountIndexStart,
            accountIndexEnd: config.accountIndexEnd))
        .toList();
  }

  @override
  Future<bool> update(entity.WalletConfig config) async {
    return await _walletConfigsDao.update_(local.WalletConfig(
        seedDerivation: config.seedDerivation.name,
        uuid: config.uuid,
        network: config.network.name,
        basePath: config.basePath,
        accountIndexStart: config.accountIndexStart,
        accountIndexEnd: config.accountIndexEnd));
  }

  @override
  Future<int> create(entity.WalletConfig config) async {
    return await _walletConfigsDao.create(local.WalletConfig(
        seedDerivation: config.seedDerivation.name,
        uuid: config.uuid,
        network: config.network.name,
        basePath: config.basePath,
        accountIndexStart: config.accountIndexStart,
        accountIndexEnd: config.accountIndexEnd));
  }

  @override
  Future<entity.WalletConfig> findOrCreate(
      {required String basePath,
      required Network network,
      SeedDerivation? seedDerivation}) async {
    final config = await _walletConfigsDao.getByBasePathAndNetwork(
      basePath: basePath,
      network: network,
    );

    if (config != null) {
      return _mapToEntity(config);
    }

    await _walletConfigsDao.create(local.WalletConfig(
        seedDerivation: seedDerivation != null
            ? seedDerivation.name
            : SeedDerivation.bip39MnemonicToSeed.name,
        uuid: uuid.v4(),
        network: network.name,
        basePath: basePath,
        accountIndexStart: 0,
        accountIndexEnd: 0));

    final newConfig = (await _walletConfigsDao.getByBasePathAndNetwork(
      basePath: basePath,
      network: network,
    ))!;

    return _mapToEntity(newConfig);
  }
}

entity.WalletConfig _mapToEntity(local.WalletConfig config) =>
    entity.WalletConfig(
      seedDerivation: SeedDerivation.values
          .firstWhere((e) => e.name == config.seedDerivation),
      uuid: config.uuid,
      network:
          NetworkX.fromString(config.network).getOrElse(() => Network.mainnet),
      basePath: config.basePath,
      accountIndexStart: config.accountIndexStart,
      accountIndexEnd: config.accountIndexEnd,
    );
