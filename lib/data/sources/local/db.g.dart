// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
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
  @override
  List<GeneratedColumn> get $columns => [uuid];
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
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String uuid;
  const Account({required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
    };
  }

  Account copyWith({String? uuid}) => Account(
        uuid: uuid ?? this.uuid,
      );
  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => uuid.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Account && other.uuid == this.uuid);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({Value<String>? uuid, Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _accountUuidMeta =
      const VerificationMeta('accountUuid');
  @override
  late final GeneratedColumn<String> accountUuid = GeneratedColumn<String>(
      'account_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wifMeta = const VerificationMeta('wif');
  @override
  late final GeneratedColumn<String> wif = GeneratedColumn<String>(
      'wif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, accountUuid, publicKey, wif];
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
    if (data.containsKey('account_uuid')) {
      context.handle(
          _accountUuidMeta,
          accountUuid.isAcceptableOrUnknown(
              data['account_uuid']!, _accountUuidMeta));
    } else if (isInserting) {
      context.missing(_accountUuidMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('wif')) {
      context.handle(
          _wifMeta, wif.isAcceptableOrUnknown(data['wif']!, _wifMeta));
    } else if (isInserting) {
      context.missing(_wifMeta);
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
      accountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_uuid'])!,
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      wif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wif'])!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final String uuid;
  final String accountUuid;
  final String publicKey;
  final String wif;
  const Wallet(
      {required this.uuid,
      required this.accountUuid,
      required this.publicKey,
      required this.wif});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['public_key'] = Variable<String>(publicKey);
    map['wif'] = Variable<String>(wif);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
      accountUuid: Value(accountUuid),
      publicKey: Value(publicKey),
      wif: Value(wif),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      uuid: serializer.fromJson<String>(json['uuid']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      wif: serializer.fromJson<String>(json['wif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'accountUuid': serializer.toJson<String>(accountUuid),
      'publicKey': serializer.toJson<String>(publicKey),
      'wif': serializer.toJson<String>(wif),
    };
  }

  Wallet copyWith(
          {String? uuid,
          String? accountUuid,
          String? publicKey,
          String? wif}) =>
      Wallet(
        uuid: uuid ?? this.uuid,
        accountUuid: accountUuid ?? this.accountUuid,
        publicKey: publicKey ?? this.publicKey,
        wif: wif ?? this.wif,
      );
  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('publicKey: $publicKey, ')
          ..write('wif: $wif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, accountUuid, publicKey, wif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.uuid == this.uuid &&
          other.accountUuid == this.accountUuid &&
          other.publicKey == this.publicKey &&
          other.wif == this.wif);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<String> accountUuid;
  final Value<String> publicKey;
  final Value<String> wif;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.wif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    required String accountUuid,
    required String publicKey,
    required String wif,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        accountUuid = Value(accountUuid),
        publicKey = Value(publicKey),
        wif = Value(wif);
  static Insertable<Wallet> custom({
    Expression<String>? uuid,
    Expression<String>? accountUuid,
    Expression<String>? publicKey,
    Expression<String>? wif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (publicKey != null) 'public_key': publicKey,
      if (wif != null) 'wif': wif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? accountUuid,
      Value<String>? publicKey,
      Value<String>? wif,
      Value<int>? rowid}) {
    return WalletsCompanion(
      uuid: uuid ?? this.uuid,
      accountUuid: accountUuid ?? this.accountUuid,
      publicKey: publicKey ?? this.publicKey,
      wif: wif ?? this.wif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (wif.present) {
      map['wif'] = Variable<String>(wif.value);
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
          ..write('accountUuid: $accountUuid, ')
          ..write('publicKey: $publicKey, ')
          ..write('wif: $wif, ')
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
  static const VerificationMeta _walletUuidMeta =
      const VerificationMeta('walletUuid');
  @override
  late final GeneratedColumn<String> walletUuid = GeneratedColumn<String>(
      'wallet_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _derivationPathMeta =
      const VerificationMeta('derivationPath');
  @override
  late final GeneratedColumn<String> derivationPath = GeneratedColumn<String>(
      'derivation_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [walletUuid, address, derivationPath];
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
    if (data.containsKey('wallet_uuid')) {
      context.handle(
          _walletUuidMeta,
          walletUuid.isAcceptableOrUnknown(
              data['wallet_uuid']!, _walletUuidMeta));
    } else if (isInserting) {
      context.missing(_walletUuidMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('derivation_path')) {
      context.handle(
          _derivationPathMeta,
          derivationPath.isAcceptableOrUnknown(
              data['derivation_path']!, _derivationPathMeta));
    } else if (isInserting) {
      context.missing(_derivationPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address};
  @override
  Address map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Address(
      walletUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_uuid'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      derivationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}derivation_path'])!,
    );
  }

  @override
  $AddressesTable createAlias(String alias) {
    return $AddressesTable(attachedDatabase, alias);
  }
}

class Address extends DataClass implements Insertable<Address> {
  final String walletUuid;
  final String address;
  final String derivationPath;
  const Address(
      {required this.walletUuid,
      required this.address,
      required this.derivationPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wallet_uuid'] = Variable<String>(walletUuid);
    map['address'] = Variable<String>(address);
    map['derivation_path'] = Variable<String>(derivationPath);
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      walletUuid: Value(walletUuid),
      address: Value(address),
      derivationPath: Value(derivationPath),
    );
  }

  factory Address.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Address(
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
      address: serializer.fromJson<String>(json['address']),
      derivationPath: serializer.fromJson<String>(json['derivationPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'walletUuid': serializer.toJson<String>(walletUuid),
      'address': serializer.toJson<String>(address),
      'derivationPath': serializer.toJson<String>(derivationPath),
    };
  }

  Address copyWith(
          {String? walletUuid, String? address, String? derivationPath}) =>
      Address(
        walletUuid: walletUuid ?? this.walletUuid,
        address: address ?? this.address,
        derivationPath: derivationPath ?? this.derivationPath,
      );
  @override
  String toString() {
    return (StringBuffer('Address(')
          ..write('walletUuid: $walletUuid, ')
          ..write('address: $address, ')
          ..write('derivationPath: $derivationPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(walletUuid, address, derivationPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          other.walletUuid == this.walletUuid &&
          other.address == this.address &&
          other.derivationPath == this.derivationPath);
}

class AddressesCompanion extends UpdateCompanion<Address> {
  final Value<String> walletUuid;
  final Value<String> address;
  final Value<String> derivationPath;
  final Value<int> rowid;
  const AddressesCompanion({
    this.walletUuid = const Value.absent(),
    this.address = const Value.absent(),
    this.derivationPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressesCompanion.insert({
    required String walletUuid,
    required String address,
    required String derivationPath,
    this.rowid = const Value.absent(),
  })  : walletUuid = Value(walletUuid),
        address = Value(address),
        derivationPath = Value(derivationPath);
  static Insertable<Address> custom({
    Expression<String>? walletUuid,
    Expression<String>? address,
    Expression<String>? derivationPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (address != null) 'address': address,
      if (derivationPath != null) 'derivation_path': derivationPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressesCompanion copyWith(
      {Value<String>? walletUuid,
      Value<String>? address,
      Value<String>? derivationPath,
      Value<int>? rowid}) {
    return AddressesCompanion(
      walletUuid: walletUuid ?? this.walletUuid,
      address: address ?? this.address,
      derivationPath: derivationPath ?? this.derivationPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (walletUuid.present) {
      map['wallet_uuid'] = Variable<String>(walletUuid.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (derivationPath.present) {
      map['derivation_path'] = Variable<String>(derivationPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddressesCompanion(')
          ..write('walletUuid: $walletUuid, ')
          ..write('address: $address, ')
          ..write('derivationPath: $derivationPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DB extends GeneratedDatabase {
  _$DB(QueryExecutor e) : super(e);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [accounts, wallets, addresses];
}