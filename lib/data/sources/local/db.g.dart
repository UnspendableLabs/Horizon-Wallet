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
  @override
  List<GeneratedColumn> get $columns => [uuid];
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
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final String uuid;
  const Wallet({required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
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

  Wallet copyWith({String? uuid}) => Wallet(
        uuid: uuid ?? this.uuid,
      );
  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => uuid.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Wallet && other.uuid == this.uuid);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<Wallet> custom({
    Expression<String>? uuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith({Value<String>? uuid, Value<int>? rowid}) {
    return WalletsCompanion(
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
    return (StringBuffer('WalletsCompanion(')
          ..write('uuid: $uuid, ')
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
  static const VerificationMeta _rootPublicKeyMeta =
      const VerificationMeta('rootPublicKey');
  @override
  late final GeneratedColumn<String> rootPublicKey = GeneratedColumn<String>(
      'root_public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rootPrivateKeyMeta =
      const VerificationMeta('rootPrivateKey');
  @override
  late final GeneratedColumn<String> rootPrivateKey = GeneratedColumn<String>(
      'root_private_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, name, walletUuid, rootPublicKey, rootPrivateKey];
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
    if (data.containsKey('root_public_key')) {
      context.handle(
          _rootPublicKeyMeta,
          rootPublicKey.isAcceptableOrUnknown(
              data['root_public_key']!, _rootPublicKeyMeta));
    } else if (isInserting) {
      context.missing(_rootPublicKeyMeta);
    }
    if (data.containsKey('root_private_key')) {
      context.handle(
          _rootPrivateKeyMeta,
          rootPrivateKey.isAcceptableOrUnknown(
              data['root_private_key']!, _rootPrivateKeyMeta));
    } else if (isInserting) {
      context.missing(_rootPrivateKeyMeta);
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
      rootPublicKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}root_public_key'])!,
      rootPrivateKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}root_private_key'])!,
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
  final String rootPublicKey;
  final String rootPrivateKey;
  const Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.rootPublicKey,
      required this.rootPrivateKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    map['root_public_key'] = Variable<String>(rootPublicKey);
    map['root_private_key'] = Variable<String>(rootPrivateKey);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      walletUuid: Value(walletUuid),
      rootPublicKey: Value(rootPublicKey),
      rootPrivateKey: Value(rootPrivateKey),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
      rootPublicKey: serializer.fromJson<String>(json['rootPublicKey']),
      rootPrivateKey: serializer.fromJson<String>(json['rootPrivateKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'walletUuid': serializer.toJson<String>(walletUuid),
      'rootPublicKey': serializer.toJson<String>(rootPublicKey),
      'rootPrivateKey': serializer.toJson<String>(rootPrivateKey),
    };
  }

  Account copyWith(
          {String? uuid,
          String? name,
          String? walletUuid,
          String? rootPublicKey,
          String? rootPrivateKey}) =>
      Account(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        walletUuid: walletUuid ?? this.walletUuid,
        rootPublicKey: rootPublicKey ?? this.rootPublicKey,
        rootPrivateKey: rootPrivateKey ?? this.rootPrivateKey,
      );
  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('rootPublicKey: $rootPublicKey, ')
          ..write('rootPrivateKey: $rootPrivateKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, name, walletUuid, rootPublicKey, rootPrivateKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.walletUuid == this.walletUuid &&
          other.rootPublicKey == this.rootPublicKey &&
          other.rootPrivateKey == this.rootPrivateKey);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> walletUuid;
  final Value<String> rootPublicKey;
  final Value<String> rootPrivateKey;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.rootPublicKey = const Value.absent(),
    this.rootPrivateKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    required String name,
    required String walletUuid,
    required String rootPublicKey,
    required String rootPrivateKey,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        walletUuid = Value(walletUuid),
        rootPublicKey = Value(rootPublicKey),
        rootPrivateKey = Value(rootPrivateKey);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? walletUuid,
    Expression<String>? rootPublicKey,
    Expression<String>? rootPrivateKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (rootPublicKey != null) 'root_public_key': rootPublicKey,
      if (rootPrivateKey != null) 'root_private_key': rootPrivateKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? walletUuid,
      Value<String>? rootPublicKey,
      Value<String>? rootPrivateKey,
      Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletUuid: walletUuid ?? this.walletUuid,
      rootPublicKey: rootPublicKey ?? this.rootPublicKey,
      rootPrivateKey: rootPrivateKey ?? this.rootPrivateKey,
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
    if (rootPublicKey.present) {
      map['root_public_key'] = Variable<String>(rootPublicKey.value);
    }
    if (rootPrivateKey.present) {
      map['root_private_key'] = Variable<String>(rootPrivateKey.value);
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
          ..write('rootPublicKey: $rootPublicKey, ')
          ..write('rootPrivateKey: $rootPrivateKey, ')
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
  static const VerificationMeta _derivationPathMeta =
      const VerificationMeta('derivationPath');
  @override
  late final GeneratedColumn<String> derivationPath = GeneratedColumn<String>(
      'derivation_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      [accountUuid, address, derivationPath, publicKey, privateKeyWif];
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
    if (data.containsKey('derivation_path')) {
      context.handle(
          _derivationPathMeta,
          derivationPath.isAcceptableOrUnknown(
              data['derivation_path']!, _derivationPathMeta));
    } else if (isInserting) {
      context.missing(_derivationPathMeta);
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
      derivationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}derivation_path'])!,
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
  final String derivationPath;
  final String publicKey;
  final String privateKeyWif;
  const Address(
      {required this.accountUuid,
      required this.address,
      required this.derivationPath,
      required this.publicKey,
      required this.privateKeyWif});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_uuid'] = Variable<String>(accountUuid);
    map['address'] = Variable<String>(address);
    map['derivation_path'] = Variable<String>(derivationPath);
    map['public_key'] = Variable<String>(publicKey);
    map['private_key_wif'] = Variable<String>(privateKeyWif);
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      accountUuid: Value(accountUuid),
      address: Value(address),
      derivationPath: Value(derivationPath),
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
      derivationPath: serializer.fromJson<String>(json['derivationPath']),
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
      'derivationPath': serializer.toJson<String>(derivationPath),
      'publicKey': serializer.toJson<String>(publicKey),
      'privateKeyWif': serializer.toJson<String>(privateKeyWif),
    };
  }

  Address copyWith(
          {String? accountUuid,
          String? address,
          String? derivationPath,
          String? publicKey,
          String? privateKeyWif}) =>
      Address(
        accountUuid: accountUuid ?? this.accountUuid,
        address: address ?? this.address,
        derivationPath: derivationPath ?? this.derivationPath,
        publicKey: publicKey ?? this.publicKey,
        privateKeyWif: privateKeyWif ?? this.privateKeyWif,
      );
  @override
  String toString() {
    return (StringBuffer('Address(')
          ..write('accountUuid: $accountUuid, ')
          ..write('address: $address, ')
          ..write('derivationPath: $derivationPath, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKeyWif: $privateKeyWif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountUuid, address, derivationPath, publicKey, privateKeyWif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          other.accountUuid == this.accountUuid &&
          other.address == this.address &&
          other.derivationPath == this.derivationPath &&
          other.publicKey == this.publicKey &&
          other.privateKeyWif == this.privateKeyWif);
}

class AddressesCompanion extends UpdateCompanion<Address> {
  final Value<String> accountUuid;
  final Value<String> address;
  final Value<String> derivationPath;
  final Value<String> publicKey;
  final Value<String> privateKeyWif;
  final Value<int> rowid;
  const AddressesCompanion({
    this.accountUuid = const Value.absent(),
    this.address = const Value.absent(),
    this.derivationPath = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.privateKeyWif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressesCompanion.insert({
    required String accountUuid,
    required String address,
    required String derivationPath,
    required String publicKey,
    required String privateKeyWif,
    this.rowid = const Value.absent(),
  })  : accountUuid = Value(accountUuid),
        address = Value(address),
        derivationPath = Value(derivationPath),
        publicKey = Value(publicKey),
        privateKeyWif = Value(privateKeyWif);
  static Insertable<Address> custom({
    Expression<String>? accountUuid,
    Expression<String>? address,
    Expression<String>? derivationPath,
    Expression<String>? publicKey,
    Expression<String>? privateKeyWif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (address != null) 'address': address,
      if (derivationPath != null) 'derivation_path': derivationPath,
      if (publicKey != null) 'public_key': publicKey,
      if (privateKeyWif != null) 'private_key_wif': privateKeyWif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressesCompanion copyWith(
      {Value<String>? accountUuid,
      Value<String>? address,
      Value<String>? derivationPath,
      Value<String>? publicKey,
      Value<String>? privateKeyWif,
      Value<int>? rowid}) {
    return AddressesCompanion(
      accountUuid: accountUuid ?? this.accountUuid,
      address: address ?? this.address,
      derivationPath: derivationPath ?? this.derivationPath,
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
    if (derivationPath.present) {
      map['derivation_path'] = Variable<String>(derivationPath.value);
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
          ..write('derivationPath: $derivationPath, ')
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
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wallets, accounts, addresses];
}
