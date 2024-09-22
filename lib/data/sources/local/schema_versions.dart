import 'package:drift/internal/versioned_schema.dart' as i0;
import 'package:drift/drift.dart' as i1;
import 'package:drift/drift.dart'; // ignore_for_file: type=lint,unused_import

// GENERATED BY drift_dev, DO NOT MODIFY.
final class Schema2 extends i0.VersionedSchema {
  Schema2({required super.database}) : super(version: 2);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    wallets,
    accounts,
    addresses,
    transactions,
  ];
  late final Shape0 wallets = Shape0(
      source: i0.VersionedTable(
        entityName: 'wallets',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_3,
          _column_4,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 accounts = Shape1(
      source: i0.VersionedTable(
        entityName: 'accounts',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_5,
          _column_6,
          _column_7,
          _column_8,
          _column_9,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape2 addresses = Shape2(
      source: i0.VersionedTable(
        entityName: 'addresses',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(address)',
        ],
        columns: [
          _column_10,
          _column_11,
          _column_12,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape3 transactions = Shape3(
      source: i0.VersionedTable(
        entityName: 'transactions',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(hash)',
        ],
        columns: [
          _column_13,
          _column_14,
          _column_15,
          _column_16,
          _column_17,
          _column_18,
          _column_19,
          _column_20,
          _column_21,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape0 extends i0.VersionedTable {
  Shape0({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get uuid =>
      columnsByName['uuid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get encryptedPrivKey =>
      columnsByName['encrypted_priv_key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get publicKey =>
      columnsByName['public_key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get chainCodeHex =>
      columnsByName['chain_code_hex']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_0(String aliasedName) =>
    i1.GeneratedColumn<String>('uuid', aliasedName, false,
        type: i1.DriftSqlType.string, $customConstraints: 'UNIQUE NOT NULL');
i1.GeneratedColumn<String> _column_1(String aliasedName) =>
    i1.GeneratedColumn<String>('name', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_2(String aliasedName) =>
    i1.GeneratedColumn<String>('encrypted_priv_key', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_3(String aliasedName) =>
    i1.GeneratedColumn<String>('public_key', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_4(String aliasedName) =>
    i1.GeneratedColumn<String>('chain_code_hex', aliasedName, false,
        type: i1.DriftSqlType.string);

class Shape1 extends i0.VersionedTable {
  Shape1({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get uuid =>
      columnsByName['uuid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get walletUuid =>
      columnsByName['wallet_uuid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get purpose =>
      columnsByName['purpose']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get coinType =>
      columnsByName['coin_type']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get accountIndex =>
      columnsByName['account_index']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get importFormat =>
      columnsByName['import_format']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_5(String aliasedName) =>
    i1.GeneratedColumn<String>('wallet_uuid', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_6(String aliasedName) =>
    i1.GeneratedColumn<String>('purpose', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_7(String aliasedName) =>
    i1.GeneratedColumn<String>('coin_type', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_8(String aliasedName) =>
    i1.GeneratedColumn<String>('account_index', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_9(String aliasedName) =>
    i1.GeneratedColumn<String>('import_format', aliasedName, false,
        type: i1.DriftSqlType.string);

class Shape2 extends i0.VersionedTable {
  Shape2({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get accountUuid =>
      columnsByName['account_uuid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get address =>
      columnsByName['address']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get index =>
      columnsByName['index']! as i1.GeneratedColumn<int>;
}

i1.GeneratedColumn<String> _column_10(String aliasedName) =>
    i1.GeneratedColumn<String>('account_uuid', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_11(String aliasedName) =>
    i1.GeneratedColumn<String>('address', aliasedName, false,
        type: i1.DriftSqlType.string, $customConstraints: 'UNIQUE NOT NULL');
i1.GeneratedColumn<int> _column_12(String aliasedName) =>
    i1.GeneratedColumn<int>('index', aliasedName, false,
        type: i1.DriftSqlType.int);

class Shape3 extends i0.VersionedTable {
  Shape3({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get hash =>
      columnsByName['hash']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get raw =>
      columnsByName['raw']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get source =>
      columnsByName['source']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get destination =>
      columnsByName['destination']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get btcAmount =>
      columnsByName['btc_amount']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<int> get fee =>
      columnsByName['fee']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<String> get data =>
      columnsByName['data']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get unpackedData =>
      columnsByName['unpacked_data']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<DateTime> get submittedAt =>
      columnsByName['submitted_at']! as i1.GeneratedColumn<DateTime>;
}

i1.GeneratedColumn<String> _column_13(String aliasedName) =>
    i1.GeneratedColumn<String>('hash', aliasedName, false,
        type: i1.DriftSqlType.string, $customConstraints: 'UNIQUE NOT NULL');
i1.GeneratedColumn<String> _column_14(String aliasedName) =>
    i1.GeneratedColumn<String>('raw', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_15(String aliasedName) =>
    i1.GeneratedColumn<String>('source', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_16(String aliasedName) =>
    i1.GeneratedColumn<String>('destination', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_17(String aliasedName) =>
    i1.GeneratedColumn<int>('btc_amount', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<int> _column_18(String aliasedName) =>
    i1.GeneratedColumn<int>('fee', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<String> _column_19(String aliasedName) =>
    i1.GeneratedColumn<String>('data', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_20(String aliasedName) =>
    i1.GeneratedColumn<String>('unpacked_data', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<DateTime> _column_21(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('submitted_at', aliasedName, false,
        type: i1.DriftSqlType.dateTime);

final class Schema3 extends i0.VersionedSchema {
  Schema3({required super.database}) : super(version: 3);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    wallets,
    accounts,
    addresses,
    transactions,
  ];
  late final Shape4 wallets = Shape4(
      source: i0.VersionedTable(
        entityName: 'wallets',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_22,
          _column_3,
          _column_4,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 accounts = Shape1(
      source: i0.VersionedTable(
        entityName: 'accounts',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_5,
          _column_6,
          _column_7,
          _column_8,
          _column_9,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape2 addresses = Shape2(
      source: i0.VersionedTable(
        entityName: 'addresses',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(address)',
        ],
        columns: [
          _column_10,
          _column_11,
          _column_12,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape3 transactions = Shape3(
      source: i0.VersionedTable(
        entityName: 'transactions',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(hash)',
        ],
        columns: [
          _column_13,
          _column_14,
          _column_15,
          _column_16,
          _column_23,
          _column_24,
          _column_19,
          _column_25,
          _column_21,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape4 extends i0.VersionedTable {
  Shape4({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get uuid =>
      columnsByName['uuid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get encryptedPrivKey =>
      columnsByName['encrypted_priv_key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get encryptedMnemonic =>
      columnsByName['encrypted_mnemonic']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get publicKey =>
      columnsByName['public_key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get chainCodeHex =>
      columnsByName['chain_code_hex']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_22(String aliasedName) =>
    i1.GeneratedColumn<String>('encrypted_mnemonic', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_23(String aliasedName) =>
    i1.GeneratedColumn<int>('btc_amount', aliasedName, true,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<int> _column_24(String aliasedName) =>
    i1.GeneratedColumn<int>('fee', aliasedName, true,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<String> _column_25(String aliasedName) =>
    i1.GeneratedColumn<String>('unpacked_data', aliasedName, true,
        type: i1.DriftSqlType.string);

final class Schema4 extends i0.VersionedSchema {
  Schema4({required super.database}) : super(version: 4);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    wallets,
    accounts,
    addresses,
    transactions,
    lockedUtxos,
  ];
  late final Shape4 wallets = Shape4(
      source: i0.VersionedTable(
        entityName: 'wallets',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_22,
          _column_3,
          _column_4,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 accounts = Shape1(
      source: i0.VersionedTable(
        entityName: 'accounts',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(uuid)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_5,
          _column_6,
          _column_7,
          _column_8,
          _column_9,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape2 addresses = Shape2(
      source: i0.VersionedTable(
        entityName: 'addresses',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(address)',
        ],
        columns: [
          _column_10,
          _column_11,
          _column_12,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape3 transactions = Shape3(
      source: i0.VersionedTable(
        entityName: 'transactions',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(hash)',
        ],
        columns: [
          _column_13,
          _column_14,
          _column_15,
          _column_16,
          _column_23,
          _column_24,
          _column_19,
          _column_25,
          _column_21,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape5 lockedUtxos = Shape5(
      source: i0.VersionedTable(
        entityName: 'locked_utxos',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_26,
          _column_27,
          _column_28,
          _column_29,
          _column_30,
          _column_31,
          _column_32,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape5 extends i0.VersionedTable {
  Shape5({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get txHash =>
      columnsByName['tx_hash']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get txid =>
      columnsByName['txid']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get vout =>
      columnsByName['vout']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<String> get address =>
      columnsByName['address']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get value =>
      columnsByName['value']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<DateTime> get lockedAt =>
      columnsByName['locked_at']! as i1.GeneratedColumn<DateTime>;
}

i1.GeneratedColumn<String> _column_26(String aliasedName) =>
    i1.GeneratedColumn<String>('id', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_27(String aliasedName) =>
    i1.GeneratedColumn<String>('tx_hash', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_28(String aliasedName) =>
    i1.GeneratedColumn<String>('txid', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_29(String aliasedName) =>
    i1.GeneratedColumn<int>('vout', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<String> _column_30(String aliasedName) =>
    i1.GeneratedColumn<String>('address', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_31(String aliasedName) =>
    i1.GeneratedColumn<int>('value', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<DateTime> _column_32(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('locked_at', aliasedName, false,
        type: i1.DriftSqlType.dateTime, defaultValue: currentDateAndTime);
i0.MigrationStepWithVersion migrationSteps({
  required Future<void> Function(i1.Migrator m, Schema2 schema) from1To2,
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
  required Future<void> Function(i1.Migrator m, Schema4 schema) from3To4,
}) {
  return (currentVersion, database) async {
    switch (currentVersion) {
      case 1:
        final schema = Schema2(database: database);
        final migrator = i1.Migrator(database, schema);
        await from1To2(migrator, schema);
        return 2;
      case 2:
        final schema = Schema3(database: database);
        final migrator = i1.Migrator(database, schema);
        await from2To3(migrator, schema);
        return 3;
      case 3:
        final schema = Schema4(database: database);
        final migrator = i1.Migrator(database, schema);
        await from3To4(migrator, schema);
        return 4;
      default:
        throw ArgumentError.value('Unknown migration from $currentVersion');
    }
  };
}

i1.OnUpgrade stepByStep({
  required Future<void> Function(i1.Migrator m, Schema2 schema) from1To2,
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
  required Future<void> Function(i1.Migrator m, Schema4 schema) from3To4,
}) =>
    i0.VersionedSchema.stepByStepHelper(
        step: migrationSteps(
      from1To2: from1To2,
      from2To3: from2To3,
      from3To4: from3To4,
    ));
