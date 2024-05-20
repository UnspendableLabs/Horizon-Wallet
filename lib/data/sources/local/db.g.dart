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

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AccountDao get accountDao {
    return _accountDaoInstance ??= _$AccountDao(database, changeListener);
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
