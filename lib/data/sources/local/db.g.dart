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
            'CREATE TABLE IF NOT EXISTS `address` (`address` TEXT NOT NULL, `walletUuid` TEXT NOT NULL, `derivationPath` TEXT NOT NULL, PRIMARY KEY (`address`))');

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
        _accountInsertionAdapter = InsertionAdapter(
            database,
            'account',
            (Account item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                }),
        _accountUpdateAdapter = UpdateAdapter(
            database,
            'account',
            ['uuid'],
            (Account item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                }),
        _accountDeletionAdapter = DeletionAdapter(
            database,
            'account',
            ['uuid'],
            (Account item) => <String, Object?>{
                  'uuid': item.uuid,
                  'defaultWalletUUID': item.defaultWalletUUID
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Account> _accountInsertionAdapter;

  final UpdateAdapter<Account> _accountUpdateAdapter;

  final DeletionAdapter<Account> _accountDeletionAdapter;

  @override
  Future<List<Account>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM account',
        mapper: (Map<String, Object?> row) => Account(
            uuid: row['uuid'] as String,
            defaultWalletUUID: row['defaultWalletUUID'] as String?));
  }

  @override
  Future<Account?> findAccountByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM account WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => Account(
            uuid: row['uuid'] as String,
            defaultWalletUUID: row['defaultWalletUUID'] as String?),
        arguments: [uuid]);
  }

  @override
  Future<void> insertAccount(Account account) async {
    await _accountInsertionAdapter.insert(account, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _accountUpdateAdapter.update(account, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAccount(Account account) async {
    await _accountDeletionAdapter.delete(account);
  }
}

class _$WalletDao extends WalletDao {
  _$WalletDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _walletInsertionAdapter = InsertionAdapter(
            database,
            'wallet',
            (Wallet item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                }),
        _walletUpdateAdapter = UpdateAdapter(
            database,
            'wallet',
            ['uuid'],
            (Wallet item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                }),
        _walletDeletionAdapter = DeletionAdapter(
            database,
            'wallet',
            ['uuid'],
            (Wallet item) => <String, Object?>{
                  'accountUuid': item.accountUuid,
                  'uuid': item.uuid,
                  'name': item.name,
                  'wif': item.wif
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Wallet> _walletInsertionAdapter;

  final UpdateAdapter<Wallet> _walletUpdateAdapter;

  final DeletionAdapter<Wallet> _walletDeletionAdapter;

  @override
  Future<List<Wallet>> findAllWallets() async {
    return _queryAdapter.queryList('SELECT * FROM wallet',
        mapper: (Map<String, Object?> row) => Wallet(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String));
  }

  @override
  Future<Wallet?> findWalletByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM wallet WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => Wallet(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String),
        arguments: [uuid]);
  }

  @override
  Future<List<Wallet>> findWalletsByAccountUuid(String accountUuid) async {
    return _queryAdapter.queryList(
        'SELECT * FROM wallet WHERE accountUuid = ?1',
        mapper: (Map<String, Object?> row) => Wallet(
            uuid: row['uuid'] as String,
            accountUuid: row['accountUuid'] as String,
            name: row['name'] as String,
            wif: row['wif'] as String),
        arguments: [accountUuid]);
  }

  @override
  Future<void> insertWallet(Wallet wallet) async {
    await _walletInsertionAdapter.insert(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await _walletUpdateAdapter.update(wallet, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWallet(Wallet wallet) async {
    await _walletDeletionAdapter.delete(wallet);
  }
}

class _$AddressDao extends AddressDao {
  _$AddressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _addressInsertionAdapter = InsertionAdapter(
            database,
            'address',
            (Address item) => <String, Object?>{
                  'address': item.address,
                  'walletUuid': item.walletUuid,
                  'derivationPath': item.derivationPath
                }),
        _addressUpdateAdapter = UpdateAdapter(
            database,
            'address',
            ['address'],
            (Address item) => <String, Object?>{
                  'address': item.address,
                  'walletUuid': item.walletUuid,
                  'derivationPath': item.derivationPath
                }),
        _addressDeletionAdapter = DeletionAdapter(
            database,
            'address',
            ['address'],
            (Address item) => <String, Object?>{
                  'address': item.address,
                  'walletUuid': item.walletUuid,
                  'derivationPath': item.derivationPath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Address> _addressInsertionAdapter;

  final UpdateAdapter<Address> _addressUpdateAdapter;

  final DeletionAdapter<Address> _addressDeletionAdapter;

  @override
  Future<List<Address>> findAllAddresss() async {
    return _queryAdapter.queryList('SELECT * FROM address',
        mapper: (Map<String, Object?> row) => Address(
            address: row['address'] as String,
            walletUuid: row['walletUuid'] as String,
            derivationPath: row['derivationPath'] as String));
  }

  @override
  Future<Address?> findAddressByUuid(String uuid) async {
    return _queryAdapter.query('SELECT * FROM address WHERE uuid = ?1',
        mapper: (Map<String, Object?> row) => Address(
            address: row['address'] as String,
            walletUuid: row['walletUuid'] as String,
            derivationPath: row['derivationPath'] as String),
        arguments: [uuid]);
  }

  @override
  Future<List<Address>> findAddresssByAccountUuid(String accountUuid) async {
    return _queryAdapter.queryList(
        'SELECT * FROM address WHERE accountUuid = ?1',
        mapper: (Map<String, Object?> row) => Address(
            address: row['address'] as String,
            walletUuid: row['walletUuid'] as String,
            derivationPath: row['derivationPath'] as String),
        arguments: [accountUuid]);
  }

  @override
  Future<void> insertAddress(Address address) async {
    await _addressInsertionAdapter.insert(address, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAddress(Address address) async {
    await _addressUpdateAdapter.update(address, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAddress(Address address) async {
    await _addressDeletionAdapter.delete(address);
  }
}
