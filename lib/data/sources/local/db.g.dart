// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $DBBuilderContract {
  /// Adds migrations to the builder.
  $DBBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $DBBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<DB> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorDB {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DBBuilderContract databaseBuilder(String name) => _$DBBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DBBuilderContract inMemoryDatabaseBuilder() => _$DBBuilder(null);
}

class _$DBBuilder implements $DBBuilderContract {
  _$DBBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $DBBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $DBBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<DB> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$DB();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$DB extends DB {
  _$DB([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AccountDao? _accountDaoInstance;

  WalletDao? _walletDaoInstance;

  AddressDao? _addressDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `account` (`uuid` TEXT NOT NULL, `defaultWalletUUID` TEXT, PRIMARY KEY (`uuid`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `wallet` (`accountUuid` TEXT NOT NULL, `uuid` TEXT NOT NULL, `name` TEXT NOT NULL, `wif` TEXT NOT NULL, PRIMARY KEY (`uuid`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `address` (`address` TEXT NOT NULL, `derivationPath` TEXT NOT NULL, PRIMARY KEY (`address`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AccountDao get accountDao {
    return _accountDaoInstance ??= _$AccountDao(database, changeListener);
  }

  @override
  WalletDao get walletDao {
    return _walletDaoInstance ??= _$WalletDao(database, changeListener);
  }

  @override
  AddressDao get addressDao {
    return _addressDaoInstance ??= _$AddressDao(database, changeListener);
  }
}

class _$AccountDao extends AccountDao {
  _$AccountDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _accountModelInsertionAdapter = InsertionAdapter(
            database,
            'account',
            (AccountModel item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                }),
        _accountModelUpdateAdapter = UpdateAdapter(
            database,
            'account',
            ['uuid'],
            (AccountModel item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                }),
        _accountModelDeletionAdapter = DeletionAdapter(
            database,
            'account',
            ['uuid'],
            (AccountModel item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AccountModel> _accountModelInsertionAdapter;

  final UpdateAdapter<AccountModel> _accountModelUpdateAdapter;

  final DeletionAdapter<AccountModel> _accountModelDeletionAdapter;

  @override
  Future<List<AccountModel>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM account',
        mapper: (Map<String, Object?> row) => AccountModel(
            uuid: row['uuid'] as String,
            defaultWalletUUID: row['defaultWalletUUID'] as String?));
  }

  @override
  Future<AccountModel?> findAccountByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM account WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => AccountModel(
            uuid: row['uuid'] as String,
            defaultWalletUUID: row['defaultWalletUUID'] as String?),
        arguments: [uuid]);
  }

  @override
  Future<void> insertAccount(AccountModel account) async {
    await _accountModelInsertionAdapter.insert(
        account, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    await _accountModelUpdateAdapter.update(account, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAccount(AccountModel account) async {
    await _accountModelDeletionAdapter.delete(account);
  }
}

class _$WalletDao extends WalletDao {
  _$WalletDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _walletModelInsertionAdapter = InsertionAdapter(
            database,
            'wallet',
            (WalletModel item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                }),
        _walletModelUpdateAdapter = UpdateAdapter(
            database,
            'wallet',
            ['uuid'],
            (WalletModel item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                }),
        _walletModelDeletionAdapter = DeletionAdapter(
            database,
            'wallet',
            ['uuid'],
            (WalletModel item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WalletModel> _walletModelInsertionAdapter;

  final UpdateAdapter<WalletModel> _walletModelUpdateAdapter;

  final DeletionAdapter<WalletModel> _walletModelDeletionAdapter;

  @override
  Future<List<WalletModel>> findAllWallets() async {
    return _queryAdapter.queryList('SELECT * FROM wallet',
        mapper: (Map<String, Object?> row) => WalletModel(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String));
  }

  @override
  Future<WalletModel?> findWalletByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM wallet WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => WalletModel(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String),
        arguments: [uuid]);
  }

  @override
  Future<List<WalletModel>> findWalletsByAccountUuid(String accountUuid) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet WHERE accountUuid = ?1',
        mapper: (Map<String, Object?> row) => WalletModel(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String),
        arguments: [accountUuid]);
  }

  @override
  Future<void> insertWallet(WalletModel wallet) async {
    await _walletModelInsertionAdapter.insert(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await _walletModelUpdateAdapter.update(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWallet(WalletModel wallet) async {
    await _walletModelDeletionAdapter.delete(wallet);
  }
}

class _$AddressDao extends AddressDao {
  _$AddressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _addressModelInsertionAdapter = InsertionAdapter(
            database,
            'address',
            (AddressModel item) => <String, Object?>{
                  'address': item.address,
                  'derivationPath': item.derivationPath
                }),
        _addressModelUpdateAdapter = UpdateAdapter(
            database,
            'address',
            ['address'],
            (AddressModel item) => <String, Object?>{
                  'address': item.address,
                  'derivationPath': item.derivationPath
                }),
        _addressModelDeletionAdapter = DeletionAdapter(
            database,
            'address',
            ['address'],
            (AddressModel item) => <String, Object?>{
                  'address': item.address,
                  'derivationPath': item.derivationPath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AddressModel> _addressModelInsertionAdapter;

  final UpdateAdapter<AddressModel> _addressModelUpdateAdapter;

  final DeletionAdapter<AddressModel> _addressModelDeletionAdapter;

  @override
  Future<List<AddressModel>> findAllAddresss() async {
    return _queryAdapter.queryList('SELECT * FROM address',
        mapper: (Map<String, Object?> row) => AddressModel(
            address: row['address'] as String,
            derivationPath: row['derivationPath'] as String));
  }

  @override
  Future<AddressModel?> findAddressByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM address WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => AddressModel(
            address: row['address'] as String,
            derivationPath: row['derivationPath'] as String),
        arguments: [uuid]);
  }

  @override
  Future<void> insertAddress(AddressModel address) async {
    await _addressModelInsertionAdapter.insert(
        address, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    await _addressModelUpdateAdapter.update(address, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAddress(AddressModel address) async {
    await _addressModelDeletionAdapter.delete(address);
  }
}
