// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(Insertable<Wallet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final String uuid;
  final String name;
  const Wallet({required this.uuid, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
      name: Value(name),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
    };
  }

  Wallet copyWith({String? uuid, String? name}) => Wallet(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet && other.uuid == this.uuid && other.name == this.name);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    required String name,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Wallet> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? uuid, Value<String>? name, Value<int>? rowid}) {
    return WalletsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurposesTable extends Purposes with TableInfo<$PurposesTable, Purpose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurposesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _walletUuidMeta =
      const VerificationMeta('walletUuid');
  @override
  late final GeneratedColumn<String> walletUuid = GeneratedColumn<String>(
      'wallet_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, name, walletUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purposes';
  @override
  VerificationContext validateIntegrity(Insertable<Purpose> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('wallet_uuid')) {
      context.handle(
          _walletUuidMeta,
          walletUuid.isAcceptableOrUnknown(
              data['wallet_uuid']!, _walletUuidMeta));
    } else if (isInserting) {
      context.missing(_walletUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Purpose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purpose(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      walletUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_uuid'])!,
    );
  }

  @override
  $PurposesTable createAlias(String alias) {
    return $PurposesTable(attachedDatabase, alias);
  }
}

class Purpose extends DataClass implements Insertable<Purpose> {
  final String uuid;
  final String name;
  final String walletUuid;
  const Purpose(
      {required this.uuid, required this.name, required this.walletUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    return map;
  }

  PurposesCompanion toCompanion(bool nullToAbsent) {
    return PurposesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      walletUuid: Value(walletUuid),
    );
  }

  factory Purpose.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purpose(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'walletUuid': serializer.toJson<String>(walletUuid),
    };
  }

  Purpose copyWith({String? uuid, String? name, String? walletUuid}) => Purpose(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        walletUuid: walletUuid ?? this.walletUuid,
      );
  @override
  String toString() {
    return (StringBuffer('Purpose(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, walletUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purpose &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.walletUuid == this.walletUuid);
}

class PurposesCompanion extends UpdateCompanion<Purpose> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> walletUuid;
  final Value<int> rowid;
  const PurposesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurposesCompanion.insert({
    required String uuid,
    required String name,
    required String walletUuid,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        walletUuid = Value(walletUuid);
  static Insertable<Purpose> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? walletUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurposesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? walletUuid,
      Value<int>? rowid}) {
    return PurposesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletUuid: walletUuid ?? this.walletUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (walletUuid.present) {
      map['wallet_uuid'] = Variable<String>(walletUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurposesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoinsTable extends Coins with TableInfo<$CoinsTable, Coin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _purposeUuidMeta =
      const VerificationMeta('purposeUuid');
  @override
  late final GeneratedColumn<String> purposeUuid = GeneratedColumn<String>(
      'purpose_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _walletUuidMeta =
      const VerificationMeta('walletUuid');
  @override
  late final GeneratedColumn<String> walletUuid = GeneratedColumn<String>(
      'wallet_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, type, purposeUuid, walletUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coins';
  @override
  VerificationContext validateIntegrity(Insertable<Coin> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('purpose_uuid')) {
      context.handle(
          _purposeUuidMeta,
          purposeUuid.isAcceptableOrUnknown(
              data['purpose_uuid']!, _purposeUuidMeta));
    } else if (isInserting) {
      context.missing(_purposeUuidMeta);
    }
    if (data.containsKey('wallet_uuid')) {
      context.handle(
          _walletUuidMeta,
          walletUuid.isAcceptableOrUnknown(
              data['wallet_uuid']!, _walletUuidMeta));
    } else if (isInserting) {
      context.missing(_walletUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Coin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Coin(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      purposeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose_uuid'])!,
      walletUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_uuid'])!,
    );
  }

  @override
  $CoinsTable createAlias(String alias) {
    return $CoinsTable(attachedDatabase, alias);
  }
}

class Coin extends DataClass implements Insertable<Coin> {
  final String uuid;
  final int type;
  final String purposeUuid;
  final String walletUuid;
  const Coin(
      {required this.uuid,
      required this.type,
      required this.purposeUuid,
      required this.walletUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['type'] = Variable<int>(type);
    map['purpose_uuid'] = Variable<String>(purposeUuid);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    return map;
  }

  CoinsCompanion toCompanion(bool nullToAbsent) {
    return CoinsCompanion(
      uuid: Value(uuid),
      type: Value(type),
      purposeUuid: Value(purposeUuid),
      walletUuid: Value(walletUuid),
    );
  }

  factory Coin.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Coin(
      uuid: serializer.fromJson<String>(json['uuid']),
      type: serializer.fromJson<int>(json['type']),
      purposeUuid: serializer.fromJson<String>(json['purposeUuid']),
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'type': serializer.toJson<int>(type),
      'purposeUuid': serializer.toJson<String>(purposeUuid),
      'walletUuid': serializer.toJson<String>(walletUuid),
    };
  }

  Coin copyWith(
          {String? uuid, int? type, String? purposeUuid, String? walletUuid}) =>
      Coin(
        uuid: uuid ?? this.uuid,
        type: type ?? this.type,
        purposeUuid: purposeUuid ?? this.purposeUuid,
        walletUuid: walletUuid ?? this.walletUuid,
      );
  @override
  String toString() {
    return (StringBuffer('Coin(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('purposeUuid: $purposeUuid, ')
          ..write('walletUuid: $walletUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, type, purposeUuid, walletUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Coin &&
          other.uuid == this.uuid &&
          other.type == this.type &&
          other.purposeUuid == this.purposeUuid &&
          other.walletUuid == this.walletUuid);
}

class CoinsCompanion extends UpdateCompanion<Coin> {
  final Value<String> uuid;
  final Value<int> type;
  final Value<String> purposeUuid;
  final Value<String> walletUuid;
  final Value<int> rowid;
  const CoinsCompanion({
    this.uuid = const Value.absent(),
    this.type = const Value.absent(),
    this.purposeUuid = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoinsCompanion.insert({
    required String uuid,
    required int type,
    required String purposeUuid,
    required String walletUuid,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        type = Value(type),
        purposeUuid = Value(purposeUuid),
        walletUuid = Value(walletUuid);
  static Insertable<Coin> custom({
    Expression<String>? uuid,
    Expression<int>? type,
    Expression<String>? purposeUuid,
    Expression<String>? walletUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (type != null) 'type': type,
      if (purposeUuid != null) 'purpose_uuid': purposeUuid,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoinsCompanion copyWith(
      {Value<String>? uuid,
      Value<int>? type,
      Value<String>? purposeUuid,
      Value<String>? walletUuid,
      Value<int>? rowid}) {
    return CoinsCompanion(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      purposeUuid: purposeUuid ?? this.purposeUuid,
      walletUuid: walletUuid ?? this.walletUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (purposeUuid.present) {
      map['purpose_uuid'] = Variable<String>(purposeUuid.value);
    }
    if (walletUuid.present) {
      map['wallet_uuid'] = Variable<String>(walletUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('purposeUuid: $purposeUuid, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _walletUuidMeta =
      const VerificationMeta('walletUuid');
  @override
  late final GeneratedColumn<String> walletUuid = GeneratedColumn<String>(
      'wallet_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purposeUuidMeta =
      const VerificationMeta('purposeUuid');
  @override
  late final GeneratedColumn<String> purposeUuid = GeneratedColumn<String>(
      'purpose_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coinUuidMeta =
      const VerificationMeta('coinUuid');
  @override
  late final GeneratedColumn<String> coinUuid = GeneratedColumn<String>(
      'coin_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIndexMeta =
      const VerificationMeta('accountIndex');
  @override
  late final GeneratedColumn<int> accountIndex = GeneratedColumn<int>(
      'account_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _xPubMeta = const VerificationMeta('xPub');
  @override
  late final GeneratedColumn<String> xPub = GeneratedColumn<String>(
      'x_pub', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, name, walletUuid, purposeUuid, coinUuid, accountIndex, xPub];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('wallet_uuid')) {
      context.handle(
          _walletUuidMeta,
          walletUuid.isAcceptableOrUnknown(
              data['wallet_uuid']!, _walletUuidMeta));
    } else if (isInserting) {
      context.missing(_walletUuidMeta);
    }
    if (data.containsKey('purpose_uuid')) {
      context.handle(
          _purposeUuidMeta,
          purposeUuid.isAcceptableOrUnknown(
              data['purpose_uuid']!, _purposeUuidMeta));
    } else if (isInserting) {
      context.missing(_purposeUuidMeta);
    }
    if (data.containsKey('coin_uuid')) {
      context.handle(_coinUuidMeta,
          coinUuid.isAcceptableOrUnknown(data['coin_uuid']!, _coinUuidMeta));
    } else if (isInserting) {
      context.missing(_coinUuidMeta);
    }
    if (data.containsKey('account_index')) {
      context.handle(
          _accountIndexMeta,
          accountIndex.isAcceptableOrUnknown(
              data['account_index']!, _accountIndexMeta));
    } else if (isInserting) {
      context.missing(_accountIndexMeta);
    }
    if (data.containsKey('x_pub')) {
      context.handle(
          _xPubMeta, xPub.isAcceptableOrUnknown(data['x_pub']!, _xPubMeta));
    } else if (isInserting) {
      context.missing(_xPubMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      walletUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_uuid'])!,
      purposeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose_uuid'])!,
      coinUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coin_uuid'])!,
      accountIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_index'])!,
      xPub: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}x_pub'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String uuid;
  final String name;
  final String walletUuid;
  final String purposeUuid;
  final String coinUuid;
  final int accountIndex;
  final String xPub;
  const Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.purposeUuid,
      required this.coinUuid,
      required this.accountIndex,
      required this.xPub});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    map['purpose_uuid'] = Variable<String>(purposeUuid);
    map['coin_uuid'] = Variable<String>(coinUuid);
    map['account_index'] = Variable<int>(accountIndex);
    map['x_pub'] = Variable<String>(xPub);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      walletUuid: Value(walletUuid),
      purposeUuid: Value(purposeUuid),
      coinUuid: Value(coinUuid),
      accountIndex: Value(accountIndex),
      xPub: Value(xPub),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
      purposeUuid: serializer.fromJson<String>(json['purposeUuid']),
      coinUuid: serializer.fromJson<String>(json['coinUuid']),
      accountIndex: serializer.fromJson<int>(json['accountIndex']),
      xPub: serializer.fromJson<String>(json['xPub']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'walletUuid': serializer.toJson<String>(walletUuid),
      'purposeUuid': serializer.toJson<String>(purposeUuid),
      'coinUuid': serializer.toJson<String>(coinUuid),
      'accountIndex': serializer.toJson<int>(accountIndex),
      'xPub': serializer.toJson<String>(xPub),
    };
  }

  Account copyWith(
          {String? uuid,
          String? name,
          String? walletUuid,
          String? purposeUuid,
          String? coinUuid,
          int? accountIndex,
          String? xPub}) =>
      Account(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        walletUuid: walletUuid ?? this.walletUuid,
        purposeUuid: purposeUuid ?? this.purposeUuid,
        coinUuid: coinUuid ?? this.coinUuid,
        accountIndex: accountIndex ?? this.accountIndex,
        xPub: xPub ?? this.xPub,
      );
  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('purposeUuid: $purposeUuid, ')
          ..write('coinUuid: $coinUuid, ')
          ..write('accountIndex: $accountIndex, ')
          ..write('xPub: $xPub')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, name, walletUuid, purposeUuid, coinUuid, accountIndex, xPub);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.walletUuid == this.walletUuid &&
          other.purposeUuid == this.purposeUuid &&
          other.coinUuid == this.coinUuid &&
          other.accountIndex == this.accountIndex &&
          other.xPub == this.xPub);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> walletUuid;
  final Value<String> purposeUuid;
  final Value<String> coinUuid;
  final Value<int> accountIndex;
  final Value<String> xPub;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.purposeUuid = const Value.absent(),
    this.coinUuid = const Value.absent(),
    this.accountIndex = const Value.absent(),
    this.xPub = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    required String name,
    required String walletUuid,
    required String purposeUuid,
    required String coinUuid,
    required int accountIndex,
    required String xPub,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        walletUuid = Value(walletUuid),
        purposeUuid = Value(purposeUuid),
        coinUuid = Value(coinUuid),
        accountIndex = Value(accountIndex),
        xPub = Value(xPub);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? walletUuid,
    Expression<String>? purposeUuid,
    Expression<String>? coinUuid,
    Expression<int>? accountIndex,
    Expression<String>? xPub,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (purposeUuid != null) 'purpose_uuid': purposeUuid,
      if (coinUuid != null) 'coin_uuid': coinUuid,
      if (accountIndex != null) 'account_index': accountIndex,
      if (xPub != null) 'x_pub': xPub,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? walletUuid,
      Value<String>? purposeUuid,
      Value<String>? coinUuid,
      Value<int>? accountIndex,
      Value<String>? xPub,
      Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletUuid: walletUuid ?? this.walletUuid,
      purposeUuid: purposeUuid ?? this.purposeUuid,
      coinUuid: coinUuid ?? this.coinUuid,
      accountIndex: accountIndex ?? this.accountIndex,
      xPub: xPub ?? this.xPub,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (walletUuid.present) {
      map['wallet_uuid'] = Variable<String>(walletUuid.value);
    }
    if (purposeUuid.present) {
      map['purpose_uuid'] = Variable<String>(purposeUuid.value);
    }
    if (coinUuid.present) {
      map['coin_uuid'] = Variable<String>(coinUuid.value);
    }
    if (accountIndex.present) {
      map['account_index'] = Variable<int>(accountIndex.value);
    }
    if (xPub.present) {
      map['x_pub'] = Variable<String>(xPub.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('purposeUuid: $purposeUuid, ')
          ..write('coinUuid: $coinUuid, ')
          ..write('accountIndex: $accountIndex, ')
          ..write('xPub: $xPub, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AddressesTable extends Addresses
    with TableInfo<$AddressesTable, Address> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountUuidMeta =
      const VerificationMeta('accountUuid');
  @override
  late final GeneratedColumn<String> accountUuid = GeneratedColumn<String>(
      'account_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _addressIndexMeta =
      const VerificationMeta('addressIndex');
  @override
  late final GeneratedColumn<int> addressIndex = GeneratedColumn<int>(
      'address_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _privateKeyWifMeta =
      const VerificationMeta('privateKeyWif');
  @override
  late final GeneratedColumn<String> privateKeyWif = GeneratedColumn<String>(
      'private_key_wif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [accountUuid, address, addressIndex, publicKey, privateKeyWif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'addresses';
  @override
  VerificationContext validateIntegrity(Insertable<Address> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_uuid')) {
      context.handle(
          _accountUuidMeta,
          accountUuid.isAcceptableOrUnknown(
              data['account_uuid']!, _accountUuidMeta));
    } else if (isInserting) {
      context.missing(_accountUuidMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('address_index')) {
      context.handle(
          _addressIndexMeta,
          addressIndex.isAcceptableOrUnknown(
              data['address_index']!, _addressIndexMeta));
    } else if (isInserting) {
      context.missing(_addressIndexMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('private_key_wif')) {
      context.handle(
          _privateKeyWifMeta,
          privateKeyWif.isAcceptableOrUnknown(
              data['private_key_wif']!, _privateKeyWifMeta));
    } else if (isInserting) {
      context.missing(_privateKeyWifMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address};
  @override
  Address map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Address(
      accountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_uuid'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      addressIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}address_index'])!,
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      privateKeyWif: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}private_key_wif'])!,
    );
  }

  @override
  $AddressesTable createAlias(String alias) {
    return $AddressesTable(attachedDatabase, alias);
  }
}

class Address extends DataClass implements Insertable<Address> {
  final String accountUuid;
  final String address;
  final int addressIndex;
  final String publicKey;
  final String privateKeyWif;
  const Address(
      {required this.accountUuid,
      required this.address,
      required this.addressIndex,
      required this.publicKey,
      required this.privateKeyWif});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_uuid'] = Variable<String>(accountUuid);
    map['address'] = Variable<String>(address);
    map['address_index'] = Variable<int>(addressIndex);
    map['public_key'] = Variable<String>(publicKey);
    map['private_key_wif'] = Variable<String>(privateKeyWif);
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      accountUuid: Value(accountUuid),
      address: Value(address),
      addressIndex: Value(addressIndex),
      publicKey: Value(publicKey),
      privateKeyWif: Value(privateKeyWif),
    );
  }

  factory Address.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Address(
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      address: serializer.fromJson<String>(json['address']),
      addressIndex: serializer.fromJson<int>(json['addressIndex']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      privateKeyWif: serializer.fromJson<String>(json['privateKeyWif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountUuid': serializer.toJson<String>(accountUuid),
      'address': serializer.toJson<String>(address),
      'addressIndex': serializer.toJson<int>(addressIndex),
      'publicKey': serializer.toJson<String>(publicKey),
      'privateKeyWif': serializer.toJson<String>(privateKeyWif),
    };
  }

  Address copyWith(
          {String? accountUuid,
          String? address,
          int? addressIndex,
          String? publicKey,
          String? privateKeyWif}) =>
      Address(
        accountUuid: accountUuid ?? this.accountUuid,
        address: address ?? this.address,
        addressIndex: addressIndex ?? this.addressIndex,
        publicKey: publicKey ?? this.publicKey,
        privateKeyWif: privateKeyWif ?? this.privateKeyWif,
      );
  @override
  String toString() {
    return (StringBuffer('Address(')
          ..write('accountUuid: $accountUuid, ')
          ..write('address: $address, ')
          ..write('addressIndex: $addressIndex, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKeyWif: $privateKeyWif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountUuid, address, addressIndex, publicKey, privateKeyWif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          other.accountUuid == this.accountUuid &&
          other.address == this.address &&
          other.addressIndex == this.addressIndex &&
          other.publicKey == this.publicKey &&
          other.privateKeyWif == this.privateKeyWif);
}

class AddressesCompanion extends UpdateCompanion<Address> {
  final Value<String> accountUuid;
  final Value<String> address;
  final Value<int> addressIndex;
  final Value<String> publicKey;
  final Value<String> privateKeyWif;
  final Value<int> rowid;
  const AddressesCompanion({
    this.accountUuid = const Value.absent(),
    this.address = const Value.absent(),
    this.addressIndex = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.privateKeyWif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressesCompanion.insert({
    required String accountUuid,
    required String address,
    required int addressIndex,
    required String publicKey,
    required String privateKeyWif,
    this.rowid = const Value.absent(),
  })  : accountUuid = Value(accountUuid),
        address = Value(address),
        addressIndex = Value(addressIndex),
        publicKey = Value(publicKey),
        privateKeyWif = Value(privateKeyWif);
  static Insertable<Address> custom({
    Expression<String>? accountUuid,
    Expression<String>? address,
    Expression<int>? addressIndex,
    Expression<String>? publicKey,
    Expression<String>? privateKeyWif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (address != null) 'address': address,
      if (addressIndex != null) 'address_index': addressIndex,
      if (publicKey != null) 'public_key': publicKey,
      if (privateKeyWif != null) 'private_key_wif': privateKeyWif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressesCompanion copyWith(
      {Value<String>? accountUuid,
      Value<String>? address,
      Value<int>? addressIndex,
      Value<String>? publicKey,
      Value<String>? privateKeyWif,
      Value<int>? rowid}) {
    return AddressesCompanion(
      accountUuid: accountUuid ?? this.accountUuid,
      address: address ?? this.address,
      addressIndex: addressIndex ?? this.addressIndex,
      publicKey: publicKey ?? this.publicKey,
      privateKeyWif: privateKeyWif ?? this.privateKeyWif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (addressIndex.present) {
      map['address_index'] = Variable<int>(addressIndex.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (privateKeyWif.present) {
      map['private_key_wif'] = Variable<String>(privateKeyWif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddressesCompanion(')
          ..write('accountUuid: $accountUuid, ')
          ..write('address: $address, ')
          ..write('addressIndex: $addressIndex, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKeyWif: $privateKeyWif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DB extends GeneratedDatabase {
  _$DB(QueryExecutor e) : super(e);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $PurposesTable purposes = $PurposesTable(this);
  late final $CoinsTable coins = $CoinsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wallets, purposes, coins, accounts, addresses];
}
