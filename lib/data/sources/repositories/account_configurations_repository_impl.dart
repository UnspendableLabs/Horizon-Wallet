import "package:horizon/domain/repositories/account_configurations_repository.dart";
import "package:horizon/data/sources/local/dao/account_configurations_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account_configuration.dart" as entity;
import 'package:get_it/get_it.dart';

class AccountConfigurationsRepositoryImpl
    implements AccountConfigurationsRepository {
  // ignore: unused_field
  final local.DB _db;
  final AccountConfigurationsDao _accountConfigurationsDao;

  AccountConfigurationsRepositoryImpl(this._db)
      : _accountConfigurationsDao = AccountConfigurationsDao(_db);

  @override
  Future<void> deleteAll() async {
    return await _accountConfigurationsDao.deleteAll();
  }

  @override
  Future<bool> update(entity.AccountConfiguration config) async {
    return await _accountConfigurationsDao.update_(local.AccountConfiguration(
      walletUUID: config.walletUUID,
      addressIndex: config.addressIndex,
      index: config.accountIndex,
    ));
  }

  @override
  Future<int> create(entity.AccountConfiguration config) async {
    return await _accountConfigurationsDao.create(local.AccountConfiguration(
      walletUUID: config.walletUUID,
      addressIndex: config.addressIndex,
      index: config.accountIndex,
    ));
  }

  @override
  Future<entity.AccountConfiguration?> getByPrimaryKey({
    required String walletId,
    required int accountIndex,
  }) async {
    final config = await _accountConfigurationsDao.getByPrimaryKey(
      walletUUID: walletId,
      index: accountIndex,
    );

    if (config == null) {
      // the default is just index 0

      return null;
    }

    return entity.AccountConfiguration(
      walletUUID: config.walletUUID,
      addressIndex: config.addressIndex,
      accountIndex: config.index,
    );
  }

  @override
  Future<entity.AccountConfiguration> createOrUpdate(
      entity.AccountConfiguration config) async {
    final existing = await getByPrimaryKey(
      walletId: config.walletUUID,
      accountIndex: config.accountIndex,
    );

    final updateOrNew = local.AccountConfiguration(
      walletUUID: config.walletUUID,
      addressIndex: config.addressIndex,
      index: config.accountIndex,
    );

    if (existing != null) {
      await _accountConfigurationsDao.update_(updateOrNew);
    } else {
      await _accountConfigurationsDao.create(updateOrNew);
    }

    return config;
  }
}
