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
  static const VerificationMeta _encryptedPrivKeyMeta =
      const VerificationMeta('encryptedPrivKey');
  @override
  late final GeneratedColumn<String> encryptedPrivKey = GeneratedColumn<String>(
      'encrypted_priv_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chainCodeHexMeta =
      const VerificationMeta('chainCodeHex');
  @override
  late final GeneratedColumn<String> chainCodeHex = GeneratedColumn<String>(
      'chain_code_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, name, encryptedPrivKey, publicKey, chainCodeHex];
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
    if (data.containsKey('encrypted_priv_key')) {
      context.handle(
          _encryptedPrivKeyMeta,
          encryptedPrivKey.isAcceptableOrUnknown(
              data['encrypted_priv_key']!, _encryptedPrivKeyMeta));
    } else if (isInserting) {
      context.missing(_encryptedPrivKeyMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('chain_code_hex')) {
      context.handle(
          _chainCodeHexMeta,
          chainCodeHex.isAcceptableOrUnknown(
              data['chain_code_hex']!, _chainCodeHexMeta));
    } else if (isInserting) {
      context.missing(_chainCodeHexMeta);
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
      encryptedPrivKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_priv_key'])!,
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      chainCodeHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chain_code_hex'])!,
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
  final String encryptedPrivKey;
  final String publicKey;
  final String chainCodeHex;
  const Wallet(
      {required this.uuid,
      required this.name,
      required this.encryptedPrivKey,
      required this.publicKey,
      required this.chainCodeHex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['encrypted_priv_key'] = Variable<String>(encryptedPrivKey);
    map['public_key'] = Variable<String>(publicKey);
    map['chain_code_hex'] = Variable<String>(chainCodeHex);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      encryptedPrivKey: Value(encryptedPrivKey),
      publicKey: Value(publicKey),
      chainCodeHex: Value(chainCodeHex),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      encryptedPrivKey: serializer.fromJson<String>(json['encryptedPrivKey']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      chainCodeHex: serializer.fromJson<String>(json['chainCodeHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'encryptedPrivKey': serializer.toJson<String>(encryptedPrivKey),
      'publicKey': serializer.toJson<String>(publicKey),
      'chainCodeHex': serializer.toJson<String>(chainCodeHex),
    };
  }

  Wallet copyWith(
          {String? uuid,
          String? name,
          String? encryptedPrivKey,
          String? publicKey,
          String? chainCodeHex}) =>
      Wallet(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        encryptedPrivKey: encryptedPrivKey ?? this.encryptedPrivKey,
        publicKey: publicKey ?? this.publicKey,
        chainCodeHex: chainCodeHex ?? this.chainCodeHex,
      );
  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('encryptedPrivKey: $encryptedPrivKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('chainCodeHex: $chainCodeHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, name, encryptedPrivKey, publicKey, chainCodeHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.encryptedPrivKey == this.encryptedPrivKey &&
          other.publicKey == this.publicKey &&
          other.chainCodeHex == this.chainCodeHex);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> encryptedPrivKey;
  final Value<String> publicKey;
  final Value<String> chainCodeHex;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.encryptedPrivKey = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.chainCodeHex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    required String name,
    required String encryptedPrivKey,
    required String publicKey,
    required String chainCodeHex,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        encryptedPrivKey = Value(encryptedPrivKey),
        publicKey = Value(publicKey),
        chainCodeHex = Value(chainCodeHex);
  static Insertable<Wallet> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? encryptedPrivKey,
    Expression<String>? publicKey,
    Expression<String>? chainCodeHex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (encryptedPrivKey != null) 'encrypted_priv_key': encryptedPrivKey,
      if (publicKey != null) 'public_key': publicKey,
      if (chainCodeHex != null) 'chain_code_hex': chainCodeHex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? encryptedPrivKey,
      Value<String>? publicKey,
      Value<String>? chainCodeHex,
      Value<int>? rowid}) {
    return WalletsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      encryptedPrivKey: encryptedPrivKey ?? this.encryptedPrivKey,
      publicKey: publicKey ?? this.publicKey,
      chainCodeHex: chainCodeHex ?? this.chainCodeHex,
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
    if (encryptedPrivKey.present) {
      map['encrypted_priv_key'] = Variable<String>(encryptedPrivKey.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (chainCodeHex.present) {
      map['chain_code_hex'] = Variable<String>(chainCodeHex.value);
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
          ..write('encryptedPrivKey: $encryptedPrivKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('chainCodeHex: $chainCodeHex, ')
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
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coinTypeMeta =
      const VerificationMeta('coinType');
  @override
  late final GeneratedColumn<String> coinType = GeneratedColumn<String>(
      'coin_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIndexMeta =
      const VerificationMeta('accountIndex');
  @override
  late final GeneratedColumn<String> accountIndex = GeneratedColumn<String>(
      'account_index', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _importFormatMeta =
      const VerificationMeta('importFormat');
  @override
  late final GeneratedColumn<String> importFormat = GeneratedColumn<String>(
      'import_format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, name, walletUuid, purpose, coinType, accountIndex, importFormat];
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
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('coin_type')) {
      context.handle(_coinTypeMeta,
          coinType.isAcceptableOrUnknown(data['coin_type']!, _coinTypeMeta));
    } else if (isInserting) {
      context.missing(_coinTypeMeta);
    }
    if (data.containsKey('account_index')) {
      context.handle(
          _accountIndexMeta,
          accountIndex.isAcceptableOrUnknown(
              data['account_index']!, _accountIndexMeta));
    } else if (isInserting) {
      context.missing(_accountIndexMeta);
    }
    if (data.containsKey('import_format')) {
      context.handle(
          _importFormatMeta,
          importFormat.isAcceptableOrUnknown(
              data['import_format']!, _importFormatMeta));
    } else if (isInserting) {
      context.missing(_importFormatMeta);
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
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      coinType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coin_type'])!,
      accountIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_index'])!,
      importFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}import_format'])!,
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
  final String purpose;
  final String coinType;
  final String accountIndex;
  final String importFormat;
  const Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.purpose,
      required this.coinType,
      required this.accountIndex,
      required this.importFormat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    map['purpose'] = Variable<String>(purpose);
    map['coin_type'] = Variable<String>(coinType);
    map['account_index'] = Variable<String>(accountIndex);
    map['import_format'] = Variable<String>(importFormat);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      walletUuid: Value(walletUuid),
      purpose: Value(purpose),
      coinType: Value(coinType),
      accountIndex: Value(accountIndex),
      importFormat: Value(importFormat),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      walletUuid: serializer.fromJson<String>(json['walletUuid']),
      purpose: serializer.fromJson<String>(json['purpose']),
      coinType: serializer.fromJson<String>(json['coinType']),
      accountIndex: serializer.fromJson<String>(json['accountIndex']),
      importFormat: serializer.fromJson<String>(json['importFormat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'walletUuid': serializer.toJson<String>(walletUuid),
      'purpose': serializer.toJson<String>(purpose),
      'coinType': serializer.toJson<String>(coinType),
      'accountIndex': serializer.toJson<String>(accountIndex),
      'importFormat': serializer.toJson<String>(importFormat),
    };
  }

  Account copyWith(
          {String? uuid,
          String? name,
          String? walletUuid,
          String? purpose,
          String? coinType,
          String? accountIndex,
          String? importFormat}) =>
      Account(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        walletUuid: walletUuid ?? this.walletUuid,
        purpose: purpose ?? this.purpose,
        coinType: coinType ?? this.coinType,
        accountIndex: accountIndex ?? this.accountIndex,
        importFormat: importFormat ?? this.importFormat,
      );
  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('walletUuid: $walletUuid, ')
          ..write('purpose: $purpose, ')
          ..write('coinType: $coinType, ')
          ..write('accountIndex: $accountIndex, ')
          ..write('importFormat: $importFormat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, name, walletUuid, purpose, coinType, accountIndex, importFormat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.walletUuid == this.walletUuid &&
          other.purpose == this.purpose &&
          other.coinType == this.coinType &&
          other.accountIndex == this.accountIndex &&
          other.importFormat == this.importFormat);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> walletUuid;
  final Value<String> purpose;
  final Value<String> coinType;
  final Value<String> accountIndex;
  final Value<String> importFormat;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.purpose = const Value.absent(),
    this.coinType = const Value.absent(),
    this.accountIndex = const Value.absent(),
    this.importFormat = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    required String name,
    required String walletUuid,
    required String purpose,
    required String coinType,
    required String accountIndex,
    required String importFormat,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        walletUuid = Value(walletUuid),
        purpose = Value(purpose),
        coinType = Value(coinType),
        accountIndex = Value(accountIndex),
        importFormat = Value(importFormat);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? walletUuid,
    Expression<String>? purpose,
    Expression<String>? coinType,
    Expression<String>? accountIndex,
    Expression<String>? importFormat,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (purpose != null) 'purpose': purpose,
      if (coinType != null) 'coin_type': coinType,
      if (accountIndex != null) 'account_index': accountIndex,
      if (importFormat != null) 'import_format': importFormat,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? walletUuid,
      Value<String>? purpose,
      Value<String>? coinType,
      Value<String>? accountIndex,
      Value<String>? importFormat,
      Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletUuid: walletUuid ?? this.walletUuid,
      purpose: purpose ?? this.purpose,
      coinType: coinType ?? this.coinType,
      accountIndex: accountIndex ?? this.accountIndex,
      importFormat: importFormat ?? this.importFormat,
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
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (coinType.present) {
      map['coin_type'] = Variable<String>(coinType.value);
    }
    if (accountIndex.present) {
      map['account_index'] = Variable<String>(accountIndex.value);
    }
    if (importFormat.present) {
      map['import_format'] = Variable<String>(importFormat.value);
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
          ..write('purpose: $purpose, ')
          ..write('coinType: $coinType, ')
          ..write('accountIndex: $accountIndex, ')
          ..write('importFormat: $importFormat, ')
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
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
      'index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [accountUuid, address, index];
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
    if (data.containsKey('index')) {
      context.handle(
          _indexMeta, index.isAcceptableOrUnknown(data['index']!, _indexMeta));
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountUuid, index};
  @override
  Address map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Address(
      accountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_uuid'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
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
  final int index;
  const Address(
      {required this.accountUuid, required this.address, required this.index});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_uuid'] = Variable<String>(accountUuid);
    map['address'] = Variable<String>(address);
    map['index'] = Variable<int>(index);
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      accountUuid: Value(accountUuid),
      address: Value(address),
      index: Value(index),
    );
  }

  factory Address.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Address(
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      address: serializer.fromJson<String>(json['address']),
      index: serializer.fromJson<int>(json['index']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountUuid': serializer.toJson<String>(accountUuid),
      'address': serializer.toJson<String>(address),
      'index': serializer.toJson<int>(index),
    };
  }

  Address copyWith({String? accountUuid, String? address, int? index}) =>
      Address(
        accountUuid: accountUuid ?? this.accountUuid,
        address: address ?? this.address,
        index: index ?? this.index,
      );
  @override
  String toString() {
    return (StringBuffer('Address(')
          ..write('accountUuid: $accountUuid, ')
          ..write('address: $address, ')
          ..write('index: $index')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountUuid, address, index);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          other.accountUuid == this.accountUuid &&
          other.address == this.address &&
          other.index == this.index);
}

class AddressesCompanion extends UpdateCompanion<Address> {
  final Value<String> accountUuid;
  final Value<String> address;
  final Value<int> index;
  final Value<int> rowid;
  const AddressesCompanion({
    this.accountUuid = const Value.absent(),
    this.address = const Value.absent(),
    this.index = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressesCompanion.insert({
    required String accountUuid,
    required String address,
    required int index,
    this.rowid = const Value.absent(),
  })  : accountUuid = Value(accountUuid),
        address = Value(address),
        index = Value(index);
  static Insertable<Address> custom({
    Expression<String>? accountUuid,
    Expression<String>? address,
    Expression<int>? index,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (address != null) 'address': address,
      if (index != null) 'index': index,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressesCompanion copyWith(
      {Value<String>? accountUuid,
      Value<String>? address,
      Value<int>? index,
      Value<int>? rowid}) {
    return AddressesCompanion(
      accountUuid: accountUuid ?? this.accountUuid,
      address: address ?? this.address,
      index: index ?? this.index,
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
    if (index.present) {
      map['index'] = Variable<int>(index.value);
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
          ..write('index: $index, ')
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
