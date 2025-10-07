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
  static const VerificationMeta _encryptedMnemonicMeta =
      const VerificationMeta('encryptedMnemonic');
  @override
  late final GeneratedColumn<String> encryptedMnemonic =
      GeneratedColumn<String>('encrypted_mnemonic', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
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
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        encryptedPrivKey,
        encryptedMnemonic,
        publicKey,
        chainCodeHex
      ];
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
    if (data.containsKey('encrypted_mnemonic')) {
      context.handle(
          _encryptedMnemonicMeta,
          encryptedMnemonic.isAcceptableOrUnknown(
              data['encrypted_mnemonic']!, _encryptedMnemonicMeta));
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
      encryptedMnemonic: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_mnemonic']),
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
  final String? encryptedMnemonic;
  final String publicKey;
  final String chainCodeHex;
  const Wallet(
      {required this.uuid,
      required this.name,
      required this.encryptedPrivKey,
      this.encryptedMnemonic,
      required this.publicKey,
      required this.chainCodeHex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['encrypted_priv_key'] = Variable<String>(encryptedPrivKey);
    if (!nullToAbsent || encryptedMnemonic != null) {
      map['encrypted_mnemonic'] = Variable<String>(encryptedMnemonic);
    }
    map['public_key'] = Variable<String>(publicKey);
    map['chain_code_hex'] = Variable<String>(chainCodeHex);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      encryptedPrivKey: Value(encryptedPrivKey),
      encryptedMnemonic: encryptedMnemonic == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedMnemonic),
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
      encryptedMnemonic:
          serializer.fromJson<String?>(json['encryptedMnemonic']),
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
      'encryptedMnemonic': serializer.toJson<String?>(encryptedMnemonic),
      'publicKey': serializer.toJson<String>(publicKey),
      'chainCodeHex': serializer.toJson<String>(chainCodeHex),
    };
  }

  Wallet copyWith(
          {String? uuid,
          String? name,
          String? encryptedPrivKey,
          Value<String?> encryptedMnemonic = const Value.absent(),
          String? publicKey,
          String? chainCodeHex}) =>
      Wallet(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        encryptedPrivKey: encryptedPrivKey ?? this.encryptedPrivKey,
        encryptedMnemonic: encryptedMnemonic.present
            ? encryptedMnemonic.value
            : this.encryptedMnemonic,
        publicKey: publicKey ?? this.publicKey,
        chainCodeHex: chainCodeHex ?? this.chainCodeHex,
      );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      encryptedPrivKey: data.encryptedPrivKey.present
          ? data.encryptedPrivKey.value
          : this.encryptedPrivKey,
      encryptedMnemonic: data.encryptedMnemonic.present
          ? data.encryptedMnemonic.value
          : this.encryptedMnemonic,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      chainCodeHex: data.chainCodeHex.present
          ? data.chainCodeHex.value
          : this.chainCodeHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('encryptedPrivKey: $encryptedPrivKey, ')
          ..write('encryptedMnemonic: $encryptedMnemonic, ')
          ..write('publicKey: $publicKey, ')
          ..write('chainCodeHex: $chainCodeHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, name, encryptedPrivKey, encryptedMnemonic, publicKey, chainCodeHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.encryptedPrivKey == this.encryptedPrivKey &&
          other.encryptedMnemonic == this.encryptedMnemonic &&
          other.publicKey == this.publicKey &&
          other.chainCodeHex == this.chainCodeHex);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> encryptedPrivKey;
  final Value<String?> encryptedMnemonic;
  final Value<String> publicKey;
  final Value<String> chainCodeHex;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.encryptedPrivKey = const Value.absent(),
    this.encryptedMnemonic = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.chainCodeHex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    required String name,
    required String encryptedPrivKey,
    this.encryptedMnemonic = const Value.absent(),
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
    Expression<String>? encryptedMnemonic,
    Expression<String>? publicKey,
    Expression<String>? chainCodeHex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (encryptedPrivKey != null) 'encrypted_priv_key': encryptedPrivKey,
      if (encryptedMnemonic != null) 'encrypted_mnemonic': encryptedMnemonic,
      if (publicKey != null) 'public_key': publicKey,
      if (chainCodeHex != null) 'chain_code_hex': chainCodeHex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? encryptedPrivKey,
      Value<String?>? encryptedMnemonic,
      Value<String>? publicKey,
      Value<String>? chainCodeHex,
      Value<int>? rowid}) {
    return WalletsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      encryptedPrivKey: encryptedPrivKey ?? this.encryptedPrivKey,
      encryptedMnemonic: encryptedMnemonic ?? this.encryptedMnemonic,
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
    if (encryptedMnemonic.present) {
      map['encrypted_mnemonic'] = Variable<String>(encryptedMnemonic.value);
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
          ..write('encryptedMnemonic: $encryptedMnemonic, ')
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
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      walletUuid:
          data.walletUuid.present ? data.walletUuid.value : this.walletUuid,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      coinType: data.coinType.present ? data.coinType.value : this.coinType,
      accountIndex: data.accountIndex.present
          ? data.accountIndex.value
          : this.accountIndex,
      importFormat: data.importFormat.present
          ? data.importFormat.value
          : this.importFormat,
    );
  }

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
  static const VerificationMeta _encryptedPrivateKeyMeta =
      const VerificationMeta('encryptedPrivateKey');
  @override
  late final GeneratedColumn<String> encryptedPrivateKey =
      GeneratedColumn<String>('encrypted_private_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [accountUuid, address, index, encryptedPrivateKey];
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
    if (data.containsKey('encrypted_private_key')) {
      context.handle(
          _encryptedPrivateKeyMeta,
          encryptedPrivateKey.isAcceptableOrUnknown(
              data['encrypted_private_key']!, _encryptedPrivateKeyMeta));
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
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
      encryptedPrivateKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_private_key']),
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
  final String? encryptedPrivateKey;
  const Address(
      {required this.accountUuid,
      required this.address,
      required this.index,
      this.encryptedPrivateKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_uuid'] = Variable<String>(accountUuid);
    map['address'] = Variable<String>(address);
    map['index'] = Variable<int>(index);
    if (!nullToAbsent || encryptedPrivateKey != null) {
      map['encrypted_private_key'] = Variable<String>(encryptedPrivateKey);
    }
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      accountUuid: Value(accountUuid),
      address: Value(address),
      index: Value(index),
      encryptedPrivateKey: encryptedPrivateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedPrivateKey),
    );
  }

  factory Address.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Address(
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      address: serializer.fromJson<String>(json['address']),
      index: serializer.fromJson<int>(json['index']),
      encryptedPrivateKey:
          serializer.fromJson<String?>(json['encryptedPrivateKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountUuid': serializer.toJson<String>(accountUuid),
      'address': serializer.toJson<String>(address),
      'index': serializer.toJson<int>(index),
      'encryptedPrivateKey': serializer.toJson<String?>(encryptedPrivateKey),
    };
  }

  Address copyWith(
          {String? accountUuid,
          String? address,
          int? index,
          Value<String?> encryptedPrivateKey = const Value.absent()}) =>
      Address(
        accountUuid: accountUuid ?? this.accountUuid,
        address: address ?? this.address,
        index: index ?? this.index,
        encryptedPrivateKey: encryptedPrivateKey.present
            ? encryptedPrivateKey.value
            : this.encryptedPrivateKey,
      );
  Address copyWithCompanion(AddressesCompanion data) {
    return Address(
      accountUuid:
          data.accountUuid.present ? data.accountUuid.value : this.accountUuid,
      address: data.address.present ? data.address.value : this.address,
      index: data.index.present ? data.index.value : this.index,
      encryptedPrivateKey: data.encryptedPrivateKey.present
          ? data.encryptedPrivateKey.value
          : this.encryptedPrivateKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Address(')
          ..write('accountUuid: $accountUuid, ')
          ..write('address: $address, ')
          ..write('index: $index, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountUuid, address, index, encryptedPrivateKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          other.accountUuid == this.accountUuid &&
          other.address == this.address &&
          other.index == this.index &&
          other.encryptedPrivateKey == this.encryptedPrivateKey);
}

class AddressesCompanion extends UpdateCompanion<Address> {
  final Value<String> accountUuid;
  final Value<String> address;
  final Value<int> index;
  final Value<String?> encryptedPrivateKey;
  final Value<int> rowid;
  const AddressesCompanion({
    this.accountUuid = const Value.absent(),
    this.address = const Value.absent(),
    this.index = const Value.absent(),
    this.encryptedPrivateKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AddressesCompanion.insert({
    required String accountUuid,
    required String address,
    required int index,
    this.encryptedPrivateKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountUuid = Value(accountUuid),
        address = Value(address),
        index = Value(index);
  static Insertable<Address> custom({
    Expression<String>? accountUuid,
    Expression<String>? address,
    Expression<int>? index,
    Expression<String>? encryptedPrivateKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (address != null) 'address': address,
      if (index != null) 'index': index,
      if (encryptedPrivateKey != null)
        'encrypted_private_key': encryptedPrivateKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AddressesCompanion copyWith(
      {Value<String>? accountUuid,
      Value<String>? address,
      Value<int>? index,
      Value<String?>? encryptedPrivateKey,
      Value<int>? rowid}) {
    return AddressesCompanion(
      accountUuid: accountUuid ?? this.accountUuid,
      address: address ?? this.address,
      index: index ?? this.index,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
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
    if (encryptedPrivateKey.present) {
      map['encrypted_private_key'] =
          Variable<String>(encryptedPrivateKey.value);
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
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
      'raw', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _btcAmountMeta =
      const VerificationMeta('btcAmount');
  @override
  late final GeneratedColumn<int> btcAmount = GeneratedColumn<int>(
      'btc_amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
      'fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unpackedDataMeta =
      const VerificationMeta('unpackedData');
  @override
  late final GeneratedColumn<String> unpackedData = GeneratedColumn<String>(
      'unpacked_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        hash,
        raw,
        source,
        destination,
        btcAmount,
        fee,
        data,
        unpackedData,
        submittedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
          _rawMeta, raw.isAcceptableOrUnknown(data['raw']!, _rawMeta));
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    }
    if (data.containsKey('btc_amount')) {
      context.handle(_btcAmountMeta,
          btcAmount.isAcceptableOrUnknown(data['btc_amount']!, _btcAmountMeta));
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('unpacked_data')) {
      context.handle(
          _unpackedDataMeta,
          unpackedData.isAcceptableOrUnknown(
              data['unpacked_data']!, _unpackedDataMeta));
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hash};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      raw: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination']),
      btcAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}btc_amount']),
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fee']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      unpackedData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unpacked_data']),
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String hash;
  final String raw;
  final String source;
  final String? destination;
  final int? btcAmount;
  final int? fee;
  final String data;
  final String? unpackedData;
  final DateTime submittedAt;
  const Transaction(
      {required this.hash,
      required this.raw,
      required this.source,
      this.destination,
      this.btcAmount,
      this.fee,
      required this.data,
      this.unpackedData,
      required this.submittedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hash'] = Variable<String>(hash);
    map['raw'] = Variable<String>(raw);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || btcAmount != null) {
      map['btc_amount'] = Variable<int>(btcAmount);
    }
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<int>(fee);
    }
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || unpackedData != null) {
      map['unpacked_data'] = Variable<String>(unpackedData);
    }
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      hash: Value(hash),
      raw: Value(raw),
      source: Value(source),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      btcAmount: btcAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(btcAmount),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
      data: Value(data),
      unpackedData: unpackedData == null && nullToAbsent
          ? const Value.absent()
          : Value(unpackedData),
      submittedAt: Value(submittedAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      hash: serializer.fromJson<String>(json['hash']),
      raw: serializer.fromJson<String>(json['raw']),
      source: serializer.fromJson<String>(json['source']),
      destination: serializer.fromJson<String?>(json['destination']),
      btcAmount: serializer.fromJson<int?>(json['btcAmount']),
      fee: serializer.fromJson<int?>(json['fee']),
      data: serializer.fromJson<String>(json['data']),
      unpackedData: serializer.fromJson<String?>(json['unpackedData']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hash': serializer.toJson<String>(hash),
      'raw': serializer.toJson<String>(raw),
      'source': serializer.toJson<String>(source),
      'destination': serializer.toJson<String?>(destination),
      'btcAmount': serializer.toJson<int?>(btcAmount),
      'fee': serializer.toJson<int?>(fee),
      'data': serializer.toJson<String>(data),
      'unpackedData': serializer.toJson<String?>(unpackedData),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
    };
  }

  Transaction copyWith(
          {String? hash,
          String? raw,
          String? source,
          Value<String?> destination = const Value.absent(),
          Value<int?> btcAmount = const Value.absent(),
          Value<int?> fee = const Value.absent(),
          String? data,
          Value<String?> unpackedData = const Value.absent(),
          DateTime? submittedAt}) =>
      Transaction(
        hash: hash ?? this.hash,
        raw: raw ?? this.raw,
        source: source ?? this.source,
        destination: destination.present ? destination.value : this.destination,
        btcAmount: btcAmount.present ? btcAmount.value : this.btcAmount,
        fee: fee.present ? fee.value : this.fee,
        data: data ?? this.data,
        unpackedData:
            unpackedData.present ? unpackedData.value : this.unpackedData,
        submittedAt: submittedAt ?? this.submittedAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      hash: data.hash.present ? data.hash.value : this.hash,
      raw: data.raw.present ? data.raw.value : this.raw,
      source: data.source.present ? data.source.value : this.source,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      btcAmount: data.btcAmount.present ? data.btcAmount.value : this.btcAmount,
      fee: data.fee.present ? data.fee.value : this.fee,
      data: data.data.present ? data.data.value : this.data,
      unpackedData: data.unpackedData.present
          ? data.unpackedData.value
          : this.unpackedData,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('hash: $hash, ')
          ..write('raw: $raw, ')
          ..write('source: $source, ')
          ..write('destination: $destination, ')
          ..write('btcAmount: $btcAmount, ')
          ..write('fee: $fee, ')
          ..write('data: $data, ')
          ..write('unpackedData: $unpackedData, ')
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hash, raw, source, destination, btcAmount,
      fee, data, unpackedData, submittedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.hash == this.hash &&
          other.raw == this.raw &&
          other.source == this.source &&
          other.destination == this.destination &&
          other.btcAmount == this.btcAmount &&
          other.fee == this.fee &&
          other.data == this.data &&
          other.unpackedData == this.unpackedData &&
          other.submittedAt == this.submittedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> hash;
  final Value<String> raw;
  final Value<String> source;
  final Value<String?> destination;
  final Value<int?> btcAmount;
  final Value<int?> fee;
  final Value<String> data;
  final Value<String?> unpackedData;
  final Value<DateTime> submittedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.hash = const Value.absent(),
    this.raw = const Value.absent(),
    this.source = const Value.absent(),
    this.destination = const Value.absent(),
    this.btcAmount = const Value.absent(),
    this.fee = const Value.absent(),
    this.data = const Value.absent(),
    this.unpackedData = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String hash,
    required String raw,
    required String source,
    this.destination = const Value.absent(),
    this.btcAmount = const Value.absent(),
    this.fee = const Value.absent(),
    required String data,
    this.unpackedData = const Value.absent(),
    required DateTime submittedAt,
    this.rowid = const Value.absent(),
  })  : hash = Value(hash),
        raw = Value(raw),
        source = Value(source),
        data = Value(data),
        submittedAt = Value(submittedAt);
  static Insertable<Transaction> custom({
    Expression<String>? hash,
    Expression<String>? raw,
    Expression<String>? source,
    Expression<String>? destination,
    Expression<int>? btcAmount,
    Expression<int>? fee,
    Expression<String>? data,
    Expression<String>? unpackedData,
    Expression<DateTime>? submittedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hash != null) 'hash': hash,
      if (raw != null) 'raw': raw,
      if (source != null) 'source': source,
      if (destination != null) 'destination': destination,
      if (btcAmount != null) 'btc_amount': btcAmount,
      if (fee != null) 'fee': fee,
      if (data != null) 'data': data,
      if (unpackedData != null) 'unpacked_data': unpackedData,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? hash,
      Value<String>? raw,
      Value<String>? source,
      Value<String?>? destination,
      Value<int?>? btcAmount,
      Value<int?>? fee,
      Value<String>? data,
      Value<String?>? unpackedData,
      Value<DateTime>? submittedAt,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      hash: hash ?? this.hash,
      raw: raw ?? this.raw,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      btcAmount: btcAmount ?? this.btcAmount,
      fee: fee ?? this.fee,
      data: data ?? this.data,
      unpackedData: unpackedData ?? this.unpackedData,
      submittedAt: submittedAt ?? this.submittedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (btcAmount.present) {
      map['btc_amount'] = Variable<int>(btcAmount.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (unpackedData.present) {
      map['unpacked_data'] = Variable<String>(unpackedData.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('hash: $hash, ')
          ..write('raw: $raw, ')
          ..write('source: $source, ')
          ..write('destination: $destination, ')
          ..write('btcAmount: $btcAmount, ')
          ..write('fee: $fee, ')
          ..write('data: $data, ')
          ..write('unpackedData: $unpackedData, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedAddressesTable extends ImportedAddresses
    with TableInfo<$ImportedAddressesTable, ImportedAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL UNIQUE');
  static const VerificationMeta _encryptedWifMeta =
      const VerificationMeta('encryptedWif');
  @override
  late final GeneratedColumn<String> encryptedWif = GeneratedColumn<String>(
      'encrypted_wif', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
      'network', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _type_Meta = const VerificationMeta('type_');
  @override
  late final GeneratedColumn<String> type_ = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [address, encryptedWif, network, type_];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_addresses';
  @override
  VerificationContext validateIntegrity(Insertable<ImportedAddress> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('encrypted_wif')) {
      context.handle(
          _encryptedWifMeta,
          encryptedWif.isAcceptableOrUnknown(
              data['encrypted_wif']!, _encryptedWifMeta));
    } else if (isInserting) {
      context.missing(_encryptedWifMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _type_Meta, type_.isAcceptableOrUnknown(data['type']!, _type_Meta));
    } else if (isInserting) {
      context.missing(_type_Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address};
  @override
  ImportedAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedAddress(
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      encryptedWif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encrypted_wif'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network'])!,
      type_: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $ImportedAddressesTable createAlias(String alias) {
    return $ImportedAddressesTable(attachedDatabase, alias);
  }
}

class ImportedAddress extends DataClass implements Insertable<ImportedAddress> {
  final String address;
  final String encryptedWif;
  final String network;
  final String type_;
  const ImportedAddress(
      {required this.address,
      required this.encryptedWif,
      required this.network,
      required this.type_});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['address'] = Variable<String>(address);
    map['encrypted_wif'] = Variable<String>(encryptedWif);
    map['network'] = Variable<String>(network);
    map['type'] = Variable<String>(type_);
    return map;
  }

  ImportedAddressesCompanion toCompanion(bool nullToAbsent) {
    return ImportedAddressesCompanion(
      address: Value(address),
      encryptedWif: Value(encryptedWif),
      network: Value(network),
      type_: Value(type_),
    );
  }

  factory ImportedAddress.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedAddress(
      address: serializer.fromJson<String>(json['address']),
      encryptedWif: serializer.fromJson<String>(json['encryptedWif']),
      network: serializer.fromJson<String>(json['network']),
      type_: serializer.fromJson<String>(json['type_']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'address': serializer.toJson<String>(address),
      'encryptedWif': serializer.toJson<String>(encryptedWif),
      'network': serializer.toJson<String>(network),
      'type_': serializer.toJson<String>(type_),
    };
  }

  ImportedAddress copyWith(
          {String? address,
          String? encryptedWif,
          String? network,
          String? type_}) =>
      ImportedAddress(
        address: address ?? this.address,
        encryptedWif: encryptedWif ?? this.encryptedWif,
        network: network ?? this.network,
        type_: type_ ?? this.type_,
      );
  ImportedAddress copyWithCompanion(ImportedAddressesCompanion data) {
    return ImportedAddress(
      address: data.address.present ? data.address.value : this.address,
      encryptedWif: data.encryptedWif.present
          ? data.encryptedWif.value
          : this.encryptedWif,
      network: data.network.present ? data.network.value : this.network,
      type_: data.type_.present ? data.type_.value : this.type_,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedAddress(')
          ..write('address: $address, ')
          ..write('encryptedWif: $encryptedWif, ')
          ..write('network: $network, ')
          ..write('type_: $type_')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(address, encryptedWif, network, type_);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedAddress &&
          other.address == this.address &&
          other.encryptedWif == this.encryptedWif &&
          other.network == this.network &&
          other.type_ == this.type_);
}

class ImportedAddressesCompanion extends UpdateCompanion<ImportedAddress> {
  final Value<String> address;
  final Value<String> encryptedWif;
  final Value<String> network;
  final Value<String> type_;
  final Value<int> rowid;
  const ImportedAddressesCompanion({
    this.address = const Value.absent(),
    this.encryptedWif = const Value.absent(),
    this.network = const Value.absent(),
    this.type_ = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedAddressesCompanion.insert({
    required String address,
    required String encryptedWif,
    required String network,
    required String type_,
    this.rowid = const Value.absent(),
  })  : address = Value(address),
        encryptedWif = Value(encryptedWif),
        network = Value(network),
        type_ = Value(type_);
  static Insertable<ImportedAddress> custom({
    Expression<String>? address,
    Expression<String>? encryptedWif,
    Expression<String>? network,
    Expression<String>? type_,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'address': address,
      if (encryptedWif != null) 'encrypted_wif': encryptedWif,
      if (network != null) 'network': network,
      if (type_ != null) 'type': type_,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedAddressesCompanion copyWith(
      {Value<String>? address,
      Value<String>? encryptedWif,
      Value<String>? network,
      Value<String>? type_,
      Value<int>? rowid}) {
    return ImportedAddressesCompanion(
      address: address ?? this.address,
      encryptedWif: encryptedWif ?? this.encryptedWif,
      network: network ?? this.network,
      type_: type_ ?? this.type_,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (encryptedWif.present) {
      map['encrypted_wif'] = Variable<String>(encryptedWif.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (type_.present) {
      map['type'] = Variable<String>(type_.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedAddressesCompanion(')
          ..write('address: $address, ')
          ..write('encryptedWif: $encryptedWif, ')
          ..write('network: $network, ')
          ..write('type_: $type_, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletConfigsTable extends WalletConfigs
    with TableInfo<$WalletConfigsTable, WalletConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
      'network', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _basePathMeta =
      const VerificationMeta('basePath');
  @override
  late final GeneratedColumn<String> basePath = GeneratedColumn<String>(
      'base_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIndexStartMeta =
      const VerificationMeta('accountIndexStart');
  @override
  late final GeneratedColumn<int> accountIndexStart = GeneratedColumn<int>(
      'account_index_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accountIndexEndMeta =
      const VerificationMeta('accountIndexEnd');
  @override
  late final GeneratedColumn<int> accountIndexEnd = GeneratedColumn<int>(
      'account_index_end', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _seedDerivationMeta =
      const VerificationMeta('seedDerivation');
  @override
  late final GeneratedColumn<String> seedDerivation = GeneratedColumn<String>(
      'seed_derivation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addrKindsMaskMeta =
      const VerificationMeta('addrKindsMask');
  @override
  late final GeneratedColumn<int> addrKindsMask = GeneratedColumn<int>(
      'addr_kinds_mask', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        network,
        basePath,
        accountIndexStart,
        accountIndexEnd,
        seedDerivation,
        addrKindsMask
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_configs';
  @override
  VerificationContext validateIntegrity(Insertable<WalletConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('base_path')) {
      context.handle(_basePathMeta,
          basePath.isAcceptableOrUnknown(data['base_path']!, _basePathMeta));
    } else if (isInserting) {
      context.missing(_basePathMeta);
    }
    if (data.containsKey('account_index_start')) {
      context.handle(
          _accountIndexStartMeta,
          accountIndexStart.isAcceptableOrUnknown(
              data['account_index_start']!, _accountIndexStartMeta));
    } else if (isInserting) {
      context.missing(_accountIndexStartMeta);
    }
    if (data.containsKey('account_index_end')) {
      context.handle(
          _accountIndexEndMeta,
          accountIndexEnd.isAcceptableOrUnknown(
              data['account_index_end']!, _accountIndexEndMeta));
    } else if (isInserting) {
      context.missing(_accountIndexEndMeta);
    }
    if (data.containsKey('seed_derivation')) {
      context.handle(
          _seedDerivationMeta,
          seedDerivation.isAcceptableOrUnknown(
              data['seed_derivation']!, _seedDerivationMeta));
    } else if (isInserting) {
      context.missing(_seedDerivationMeta);
    }
    if (data.containsKey('addr_kinds_mask')) {
      context.handle(
          _addrKindsMaskMeta,
          addrKindsMask.isAcceptableOrUnknown(
              data['addr_kinds_mask']!, _addrKindsMaskMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {network, basePath, seedDerivation};
  @override
  WalletConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletConfig(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network'])!,
      basePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_path'])!,
      accountIndexStart: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}account_index_start'])!,
      accountIndexEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_index_end'])!,
      seedDerivation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}seed_derivation'])!,
      addrKindsMask: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}addr_kinds_mask'])!,
    );
  }

  @override
  $WalletConfigsTable createAlias(String alias) {
    return $WalletConfigsTable(attachedDatabase, alias);
  }
}

class WalletConfig extends DataClass implements Insertable<WalletConfig> {
  final String uuid;
  final String network;
  final String basePath;
  final int accountIndexStart;
  final int accountIndexEnd;
  final String seedDerivation;
  final int addrKindsMask;
  const WalletConfig(
      {required this.uuid,
      required this.network,
      required this.basePath,
      required this.accountIndexStart,
      required this.accountIndexEnd,
      required this.seedDerivation,
      required this.addrKindsMask});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['network'] = Variable<String>(network);
    map['base_path'] = Variable<String>(basePath);
    map['account_index_start'] = Variable<int>(accountIndexStart);
    map['account_index_end'] = Variable<int>(accountIndexEnd);
    map['seed_derivation'] = Variable<String>(seedDerivation);
    map['addr_kinds_mask'] = Variable<int>(addrKindsMask);
    return map;
  }

  WalletConfigsCompanion toCompanion(bool nullToAbsent) {
    return WalletConfigsCompanion(
      uuid: Value(uuid),
      network: Value(network),
      basePath: Value(basePath),
      accountIndexStart: Value(accountIndexStart),
      accountIndexEnd: Value(accountIndexEnd),
      seedDerivation: Value(seedDerivation),
      addrKindsMask: Value(addrKindsMask),
    );
  }

  factory WalletConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletConfig(
      uuid: serializer.fromJson<String>(json['uuid']),
      network: serializer.fromJson<String>(json['network']),
      basePath: serializer.fromJson<String>(json['basePath']),
      accountIndexStart: serializer.fromJson<int>(json['accountIndexStart']),
      accountIndexEnd: serializer.fromJson<int>(json['accountIndexEnd']),
      seedDerivation: serializer.fromJson<String>(json['seedDerivation']),
      addrKindsMask: serializer.fromJson<int>(json['addrKindsMask']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'network': serializer.toJson<String>(network),
      'basePath': serializer.toJson<String>(basePath),
      'accountIndexStart': serializer.toJson<int>(accountIndexStart),
      'accountIndexEnd': serializer.toJson<int>(accountIndexEnd),
      'seedDerivation': serializer.toJson<String>(seedDerivation),
      'addrKindsMask': serializer.toJson<int>(addrKindsMask),
    };
  }

  WalletConfig copyWith(
          {String? uuid,
          String? network,
          String? basePath,
          int? accountIndexStart,
          int? accountIndexEnd,
          String? seedDerivation,
          int? addrKindsMask}) =>
      WalletConfig(
        uuid: uuid ?? this.uuid,
        network: network ?? this.network,
        basePath: basePath ?? this.basePath,
        accountIndexStart: accountIndexStart ?? this.accountIndexStart,
        accountIndexEnd: accountIndexEnd ?? this.accountIndexEnd,
        seedDerivation: seedDerivation ?? this.seedDerivation,
        addrKindsMask: addrKindsMask ?? this.addrKindsMask,
      );
  WalletConfig copyWithCompanion(WalletConfigsCompanion data) {
    return WalletConfig(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      network: data.network.present ? data.network.value : this.network,
      basePath: data.basePath.present ? data.basePath.value : this.basePath,
      accountIndexStart: data.accountIndexStart.present
          ? data.accountIndexStart.value
          : this.accountIndexStart,
      accountIndexEnd: data.accountIndexEnd.present
          ? data.accountIndexEnd.value
          : this.accountIndexEnd,
      seedDerivation: data.seedDerivation.present
          ? data.seedDerivation.value
          : this.seedDerivation,
      addrKindsMask: data.addrKindsMask.present
          ? data.addrKindsMask.value
          : this.addrKindsMask,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletConfig(')
          ..write('uuid: $uuid, ')
          ..write('network: $network, ')
          ..write('basePath: $basePath, ')
          ..write('accountIndexStart: $accountIndexStart, ')
          ..write('accountIndexEnd: $accountIndexEnd, ')
          ..write('seedDerivation: $seedDerivation, ')
          ..write('addrKindsMask: $addrKindsMask')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, network, basePath, accountIndexStart,
      accountIndexEnd, seedDerivation, addrKindsMask);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletConfig &&
          other.uuid == this.uuid &&
          other.network == this.network &&
          other.basePath == this.basePath &&
          other.accountIndexStart == this.accountIndexStart &&
          other.accountIndexEnd == this.accountIndexEnd &&
          other.seedDerivation == this.seedDerivation &&
          other.addrKindsMask == this.addrKindsMask);
}

class WalletConfigsCompanion extends UpdateCompanion<WalletConfig> {
  final Value<String> uuid;
  final Value<String> network;
  final Value<String> basePath;
  final Value<int> accountIndexStart;
  final Value<int> accountIndexEnd;
  final Value<String> seedDerivation;
  final Value<int> addrKindsMask;
  final Value<int> rowid;
  const WalletConfigsCompanion({
    this.uuid = const Value.absent(),
    this.network = const Value.absent(),
    this.basePath = const Value.absent(),
    this.accountIndexStart = const Value.absent(),
    this.accountIndexEnd = const Value.absent(),
    this.seedDerivation = const Value.absent(),
    this.addrKindsMask = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletConfigsCompanion.insert({
    required String uuid,
    required String network,
    required String basePath,
    required int accountIndexStart,
    required int accountIndexEnd,
    required String seedDerivation,
    this.addrKindsMask = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        network = Value(network),
        basePath = Value(basePath),
        accountIndexStart = Value(accountIndexStart),
        accountIndexEnd = Value(accountIndexEnd),
        seedDerivation = Value(seedDerivation);
  static Insertable<WalletConfig> custom({
    Expression<String>? uuid,
    Expression<String>? network,
    Expression<String>? basePath,
    Expression<int>? accountIndexStart,
    Expression<int>? accountIndexEnd,
    Expression<String>? seedDerivation,
    Expression<int>? addrKindsMask,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (network != null) 'network': network,
      if (basePath != null) 'base_path': basePath,
      if (accountIndexStart != null) 'account_index_start': accountIndexStart,
      if (accountIndexEnd != null) 'account_index_end': accountIndexEnd,
      if (seedDerivation != null) 'seed_derivation': seedDerivation,
      if (addrKindsMask != null) 'addr_kinds_mask': addrKindsMask,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletConfigsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? network,
      Value<String>? basePath,
      Value<int>? accountIndexStart,
      Value<int>? accountIndexEnd,
      Value<String>? seedDerivation,
      Value<int>? addrKindsMask,
      Value<int>? rowid}) {
    return WalletConfigsCompanion(
      uuid: uuid ?? this.uuid,
      network: network ?? this.network,
      basePath: basePath ?? this.basePath,
      accountIndexStart: accountIndexStart ?? this.accountIndexStart,
      accountIndexEnd: accountIndexEnd ?? this.accountIndexEnd,
      seedDerivation: seedDerivation ?? this.seedDerivation,
      addrKindsMask: addrKindsMask ?? this.addrKindsMask,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (basePath.present) {
      map['base_path'] = Variable<String>(basePath.value);
    }
    if (accountIndexStart.present) {
      map['account_index_start'] = Variable<int>(accountIndexStart.value);
    }
    if (accountIndexEnd.present) {
      map['account_index_end'] = Variable<int>(accountIndexEnd.value);
    }
    if (seedDerivation.present) {
      map['seed_derivation'] = Variable<String>(seedDerivation.value);
    }
    if (addrKindsMask.present) {
      map['addr_kinds_mask'] = Variable<int>(addrKindsMask.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletConfigsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('network: $network, ')
          ..write('basePath: $basePath, ')
          ..write('accountIndexStart: $accountIndexStart, ')
          ..write('accountIndexEnd: $accountIndexEnd, ')
          ..write('seedDerivation: $seedDerivation, ')
          ..write('addrKindsMask: $addrKindsMask, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountConfigurationsTable extends AccountConfigurations
    with TableInfo<$AccountConfigurationsTable, AccountConfiguration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _walletUUIDMeta =
      const VerificationMeta('walletUUID');
  @override
  late final GeneratedColumn<String> walletUUID = GeneratedColumn<String>(
      'wallet_u_u_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
      'index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addressIndexMeta =
      const VerificationMeta('addressIndex');
  @override
  late final GeneratedColumn<int> addressIndex = GeneratedColumn<int>(
      'address_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [walletUUID, index, addressIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_configurations';
  @override
  VerificationContext validateIntegrity(
      Insertable<AccountConfiguration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wallet_u_u_i_d')) {
      context.handle(
          _walletUUIDMeta,
          walletUUID.isAcceptableOrUnknown(
              data['wallet_u_u_i_d']!, _walletUUIDMeta));
    } else if (isInserting) {
      context.missing(_walletUUIDMeta);
    }
    if (data.containsKey('index')) {
      context.handle(
          _indexMeta, index.isAcceptableOrUnknown(data['index']!, _indexMeta));
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    if (data.containsKey('address_index')) {
      context.handle(
          _addressIndexMeta,
          addressIndex.isAcceptableOrUnknown(
              data['address_index']!, _addressIndexMeta));
    } else if (isInserting) {
      context.missing(_addressIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {walletUUID, index};
  @override
  AccountConfiguration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountConfiguration(
      walletUUID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_u_u_i_d'])!,
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
      addressIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}address_index'])!,
    );
  }

  @override
  $AccountConfigurationsTable createAlias(String alias) {
    return $AccountConfigurationsTable(attachedDatabase, alias);
  }
}

class AccountConfiguration extends DataClass
    implements Insertable<AccountConfiguration> {
  final String walletUUID;
  final int index;
  final int addressIndex;
  const AccountConfiguration(
      {required this.walletUUID,
      required this.index,
      required this.addressIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wallet_u_u_i_d'] = Variable<String>(walletUUID);
    map['index'] = Variable<int>(index);
    map['address_index'] = Variable<int>(addressIndex);
    return map;
  }

  AccountConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return AccountConfigurationsCompanion(
      walletUUID: Value(walletUUID),
      index: Value(index),
      addressIndex: Value(addressIndex),
    );
  }

  factory AccountConfiguration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountConfiguration(
      walletUUID: serializer.fromJson<String>(json['walletUUID']),
      index: serializer.fromJson<int>(json['index']),
      addressIndex: serializer.fromJson<int>(json['addressIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'walletUUID': serializer.toJson<String>(walletUUID),
      'index': serializer.toJson<int>(index),
      'addressIndex': serializer.toJson<int>(addressIndex),
    };
  }

  AccountConfiguration copyWith(
          {String? walletUUID, int? index, int? addressIndex}) =>
      AccountConfiguration(
        walletUUID: walletUUID ?? this.walletUUID,
        index: index ?? this.index,
        addressIndex: addressIndex ?? this.addressIndex,
      );
  AccountConfiguration copyWithCompanion(AccountConfigurationsCompanion data) {
    return AccountConfiguration(
      walletUUID:
          data.walletUUID.present ? data.walletUUID.value : this.walletUUID,
      index: data.index.present ? data.index.value : this.index,
      addressIndex: data.addressIndex.present
          ? data.addressIndex.value
          : this.addressIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountConfiguration(')
          ..write('walletUUID: $walletUUID, ')
          ..write('index: $index, ')
          ..write('addressIndex: $addressIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(walletUUID, index, addressIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountConfiguration &&
          other.walletUUID == this.walletUUID &&
          other.index == this.index &&
          other.addressIndex == this.addressIndex);
}

class AccountConfigurationsCompanion
    extends UpdateCompanion<AccountConfiguration> {
  final Value<String> walletUUID;
  final Value<int> index;
  final Value<int> addressIndex;
  final Value<int> rowid;
  const AccountConfigurationsCompanion({
    this.walletUUID = const Value.absent(),
    this.index = const Value.absent(),
    this.addressIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountConfigurationsCompanion.insert({
    required String walletUUID,
    required int index,
    required int addressIndex,
    this.rowid = const Value.absent(),
  })  : walletUUID = Value(walletUUID),
        index = Value(index),
        addressIndex = Value(addressIndex);
  static Insertable<AccountConfiguration> custom({
    Expression<String>? walletUUID,
    Expression<int>? index,
    Expression<int>? addressIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (walletUUID != null) 'wallet_u_u_i_d': walletUUID,
      if (index != null) 'index': index,
      if (addressIndex != null) 'address_index': addressIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountConfigurationsCompanion copyWith(
      {Value<String>? walletUUID,
      Value<int>? index,
      Value<int>? addressIndex,
      Value<int>? rowid}) {
    return AccountConfigurationsCompanion(
      walletUUID: walletUUID ?? this.walletUUID,
      index: index ?? this.index,
      addressIndex: addressIndex ?? this.addressIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (walletUUID.present) {
      map['wallet_u_u_i_d'] = Variable<String>(walletUUID.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (addressIndex.present) {
      map['address_index'] = Variable<int>(addressIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountConfigurationsCompanion(')
          ..write('walletUUID: $walletUUID, ')
          ..write('index: $index, ')
          ..write('addressIndex: $addressIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UtxoAttachesTable extends UtxoAttaches
    with TableInfo<$UtxoAttachesTable, UtxoAttach> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtxoAttachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _utxoIDMeta = const VerificationMeta('utxoID');
  @override
  late final GeneratedColumn<String> utxoID = GeneratedColumn<String>(
      'utxo_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetMeta = const VerificationMeta('asset');
  @override
  late final GeneratedColumn<String> asset = GeneratedColumn<String>(
      'asset', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _divisibleMeta =
      const VerificationMeta('divisible');
  @override
  late final GeneratedColumn<bool> divisible = GeneratedColumn<bool>(
      'divisible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("divisible" IN (0, 1))'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, utxoID, asset, divisible, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utxo_attaches';
  @override
  VerificationContext validateIntegrity(Insertable<UtxoAttach> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('utxo_i_d')) {
      context.handle(_utxoIDMeta,
          utxoID.isAcceptableOrUnknown(data['utxo_i_d']!, _utxoIDMeta));
    } else if (isInserting) {
      context.missing(_utxoIDMeta);
    }
    if (data.containsKey('asset')) {
      context.handle(
          _assetMeta, asset.isAcceptableOrUnknown(data['asset']!, _assetMeta));
    } else if (isInserting) {
      context.missing(_assetMeta);
    }
    if (data.containsKey('divisible')) {
      context.handle(_divisibleMeta,
          divisible.isAcceptableOrUnknown(data['divisible']!, _divisibleMeta));
    } else if (isInserting) {
      context.missing(_divisibleMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {utxoID};
  @override
  UtxoAttach map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtxoAttach(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      utxoID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}utxo_i_d'])!,
      asset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset'])!,
      divisible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}divisible'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $UtxoAttachesTable createAlias(String alias) {
    return $UtxoAttachesTable(attachedDatabase, alias);
  }
}

class UtxoAttach extends DataClass implements Insertable<UtxoAttach> {
  final DateTime createdAt;
  final String utxoID;
  final String asset;
  final bool divisible;
  final int quantity;
  const UtxoAttach(
      {required this.createdAt,
      required this.utxoID,
      required this.asset,
      required this.divisible,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['utxo_i_d'] = Variable<String>(utxoID);
    map['asset'] = Variable<String>(asset);
    map['divisible'] = Variable<bool>(divisible);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  UtxoAttachesCompanion toCompanion(bool nullToAbsent) {
    return UtxoAttachesCompanion(
      createdAt: Value(createdAt),
      utxoID: Value(utxoID),
      asset: Value(asset),
      divisible: Value(divisible),
      quantity: Value(quantity),
    );
  }

  factory UtxoAttach.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UtxoAttach(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      utxoID: serializer.fromJson<String>(json['utxoID']),
      asset: serializer.fromJson<String>(json['asset']),
      divisible: serializer.fromJson<bool>(json['divisible']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'utxoID': serializer.toJson<String>(utxoID),
      'asset': serializer.toJson<String>(asset),
      'divisible': serializer.toJson<bool>(divisible),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  UtxoAttach copyWith(
          {DateTime? createdAt,
          String? utxoID,
          String? asset,
          bool? divisible,
          int? quantity}) =>
      UtxoAttach(
        createdAt: createdAt ?? this.createdAt,
        utxoID: utxoID ?? this.utxoID,
        asset: asset ?? this.asset,
        divisible: divisible ?? this.divisible,
        quantity: quantity ?? this.quantity,
      );
  UtxoAttach copyWithCompanion(UtxoAttachesCompanion data) {
    return UtxoAttach(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      utxoID: data.utxoID.present ? data.utxoID.value : this.utxoID,
      asset: data.asset.present ? data.asset.value : this.asset,
      divisible: data.divisible.present ? data.divisible.value : this.divisible,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UtxoAttach(')
          ..write('createdAt: $createdAt, ')
          ..write('utxoID: $utxoID, ')
          ..write('asset: $asset, ')
          ..write('divisible: $divisible, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, utxoID, asset, divisible, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtxoAttach &&
          other.createdAt == this.createdAt &&
          other.utxoID == this.utxoID &&
          other.asset == this.asset &&
          other.divisible == this.divisible &&
          other.quantity == this.quantity);
}

class UtxoAttachesCompanion extends UpdateCompanion<UtxoAttach> {
  final Value<DateTime> createdAt;
  final Value<String> utxoID;
  final Value<String> asset;
  final Value<bool> divisible;
  final Value<int> quantity;
  final Value<int> rowid;
  const UtxoAttachesCompanion({
    this.createdAt = const Value.absent(),
    this.utxoID = const Value.absent(),
    this.asset = const Value.absent(),
    this.divisible = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UtxoAttachesCompanion.insert({
    required DateTime createdAt,
    required String utxoID,
    required String asset,
    required bool divisible,
    required int quantity,
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        utxoID = Value(utxoID),
        asset = Value(asset),
        divisible = Value(divisible),
        quantity = Value(quantity);
  static Insertable<UtxoAttach> custom({
    Expression<DateTime>? createdAt,
    Expression<String>? utxoID,
    Expression<String>? asset,
    Expression<bool>? divisible,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (utxoID != null) 'utxo_i_d': utxoID,
      if (asset != null) 'asset': asset,
      if (divisible != null) 'divisible': divisible,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UtxoAttachesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<String>? utxoID,
      Value<String>? asset,
      Value<bool>? divisible,
      Value<int>? quantity,
      Value<int>? rowid}) {
    return UtxoAttachesCompanion(
      createdAt: createdAt ?? this.createdAt,
      utxoID: utxoID ?? this.utxoID,
      asset: asset ?? this.asset,
      divisible: divisible ?? this.divisible,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (utxoID.present) {
      map['utxo_i_d'] = Variable<String>(utxoID.value);
    }
    if (asset.present) {
      map['asset'] = Variable<String>(asset.value);
    }
    if (divisible.present) {
      map['divisible'] = Variable<bool>(divisible.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtxoAttachesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('utxoID: $utxoID, ')
          ..write('asset: $asset, ')
          ..write('divisible: $divisible, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DB extends GeneratedDatabase {
  _$DB(QueryExecutor e) : super(e);
  $DBManager get managers => $DBManager(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ImportedAddressesTable importedAddresses =
      $ImportedAddressesTable(this);
  late final $WalletConfigsTable walletConfigs = $WalletConfigsTable(this);
  late final $AccountConfigurationsTable accountConfigurations =
      $AccountConfigurationsTable(this);
  late final $UtxoAttachesTable utxoAttaches = $UtxoAttachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        wallets,
        accounts,
        addresses,
        transactions,
        importedAddresses,
        walletConfigs,
        accountConfigurations,
        utxoAttaches
      ];
}

typedef $$WalletsTableCreateCompanionBuilder = WalletsCompanion Function({
  required String uuid,
  required String name,
  required String encryptedPrivKey,
  Value<String?> encryptedMnemonic,
  required String publicKey,
  required String chainCodeHex,
  Value<int> rowid,
});
typedef $$WalletsTableUpdateCompanionBuilder = WalletsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String> encryptedPrivKey,
  Value<String?> encryptedMnemonic,
  Value<String> publicKey,
  Value<String> chainCodeHex,
  Value<int> rowid,
});

class $$WalletsTableFilterComposer extends Composer<_$DB, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedPrivKey => $composableBuilder(
      column: $table.encryptedPrivKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedMnemonic => $composableBuilder(
      column: $table.encryptedMnemonic,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chainCodeHex => $composableBuilder(
      column: $table.chainCodeHex, builder: (column) => ColumnFilters(column));
}

class $$WalletsTableOrderingComposer extends Composer<_$DB, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedPrivKey => $composableBuilder(
      column: $table.encryptedPrivKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedMnemonic => $composableBuilder(
      column: $table.encryptedMnemonic,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chainCodeHex => $composableBuilder(
      column: $table.chainCodeHex,
      builder: (column) => ColumnOrderings(column));
}

class $$WalletsTableAnnotationComposer extends Composer<_$DB, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get encryptedPrivKey => $composableBuilder(
      column: $table.encryptedPrivKey, builder: (column) => column);

  GeneratedColumn<String> get encryptedMnemonic => $composableBuilder(
      column: $table.encryptedMnemonic, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get chainCodeHex => $composableBuilder(
      column: $table.chainCodeHex, builder: (column) => column);
}

class $$WalletsTableTableManager extends RootTableManager<
    _$DB,
    $WalletsTable,
    Wallet,
    $$WalletsTableFilterComposer,
    $$WalletsTableOrderingComposer,
    $$WalletsTableAnnotationComposer,
    $$WalletsTableCreateCompanionBuilder,
    $$WalletsTableUpdateCompanionBuilder,
    (Wallet, BaseReferences<_$DB, $WalletsTable, Wallet>),
    Wallet,
    PrefetchHooks Function()> {
  $$WalletsTableTableManager(_$DB db, $WalletsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> encryptedPrivKey = const Value.absent(),
            Value<String?> encryptedMnemonic = const Value.absent(),
            Value<String> publicKey = const Value.absent(),
            Value<String> chainCodeHex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletsCompanion(
            uuid: uuid,
            name: name,
            encryptedPrivKey: encryptedPrivKey,
            encryptedMnemonic: encryptedMnemonic,
            publicKey: publicKey,
            chainCodeHex: chainCodeHex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            required String encryptedPrivKey,
            Value<String?> encryptedMnemonic = const Value.absent(),
            required String publicKey,
            required String chainCodeHex,
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletsCompanion.insert(
            uuid: uuid,
            name: name,
            encryptedPrivKey: encryptedPrivKey,
            encryptedMnemonic: encryptedMnemonic,
            publicKey: publicKey,
            chainCodeHex: chainCodeHex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WalletsTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $WalletsTable,
    Wallet,
    $$WalletsTableFilterComposer,
    $$WalletsTableOrderingComposer,
    $$WalletsTableAnnotationComposer,
    $$WalletsTableCreateCompanionBuilder,
    $$WalletsTableUpdateCompanionBuilder,
    (Wallet, BaseReferences<_$DB, $WalletsTable, Wallet>),
    Wallet,
    PrefetchHooks Function()>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String uuid,
  required String name,
  required String walletUuid,
  required String purpose,
  required String coinType,
  required String accountIndex,
  required String importFormat,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String> walletUuid,
  Value<String> purpose,
  Value<String> coinType,
  Value<String> accountIndex,
  Value<String> importFormat,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer extends Composer<_$DB, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get walletUuid => $composableBuilder(
      column: $table.walletUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coinType => $composableBuilder(
      column: $table.coinType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountIndex => $composableBuilder(
      column: $table.accountIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get importFormat => $composableBuilder(
      column: $table.importFormat, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer extends Composer<_$DB, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get walletUuid => $composableBuilder(
      column: $table.walletUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coinType => $composableBuilder(
      column: $table.coinType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountIndex => $composableBuilder(
      column: $table.accountIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get importFormat => $composableBuilder(
      column: $table.importFormat,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer extends Composer<_$DB, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get walletUuid => $composableBuilder(
      column: $table.walletUuid, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get coinType =>
      $composableBuilder(column: $table.coinType, builder: (column) => column);

  GeneratedColumn<String> get accountIndex => $composableBuilder(
      column: $table.accountIndex, builder: (column) => column);

  GeneratedColumn<String> get importFormat => $composableBuilder(
      column: $table.importFormat, builder: (column) => column);
}

class $$AccountsTableTableManager extends RootTableManager<
    _$DB,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$DB, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$DB db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> walletUuid = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<String> coinType = const Value.absent(),
            Value<String> accountIndex = const Value.absent(),
            Value<String> importFormat = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            uuid: uuid,
            name: name,
            walletUuid: walletUuid,
            purpose: purpose,
            coinType: coinType,
            accountIndex: accountIndex,
            importFormat: importFormat,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            required String walletUuid,
            required String purpose,
            required String coinType,
            required String accountIndex,
            required String importFormat,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            uuid: uuid,
            name: name,
            walletUuid: walletUuid,
            purpose: purpose,
            coinType: coinType,
            accountIndex: accountIndex,
            importFormat: importFormat,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$DB, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$AddressesTableCreateCompanionBuilder = AddressesCompanion Function({
  required String accountUuid,
  required String address,
  required int index,
  Value<String?> encryptedPrivateKey,
  Value<int> rowid,
});
typedef $$AddressesTableUpdateCompanionBuilder = AddressesCompanion Function({
  Value<String> accountUuid,
  Value<String> address,
  Value<int> index,
  Value<String?> encryptedPrivateKey,
  Value<int> rowid,
});

class $$AddressesTableFilterComposer extends Composer<_$DB, $AddressesTable> {
  $$AddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountUuid => $composableBuilder(
      column: $table.accountUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedPrivateKey => $composableBuilder(
      column: $table.encryptedPrivateKey,
      builder: (column) => ColumnFilters(column));
}

class $$AddressesTableOrderingComposer extends Composer<_$DB, $AddressesTable> {
  $$AddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountUuid => $composableBuilder(
      column: $table.accountUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedPrivateKey => $composableBuilder(
      column: $table.encryptedPrivateKey,
      builder: (column) => ColumnOrderings(column));
}

class $$AddressesTableAnnotationComposer
    extends Composer<_$DB, $AddressesTable> {
  $$AddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountUuid => $composableBuilder(
      column: $table.accountUuid, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<String> get encryptedPrivateKey => $composableBuilder(
      column: $table.encryptedPrivateKey, builder: (column) => column);
}

class $$AddressesTableTableManager extends RootTableManager<
    _$DB,
    $AddressesTable,
    Address,
    $$AddressesTableFilterComposer,
    $$AddressesTableOrderingComposer,
    $$AddressesTableAnnotationComposer,
    $$AddressesTableCreateCompanionBuilder,
    $$AddressesTableUpdateCompanionBuilder,
    (Address, BaseReferences<_$DB, $AddressesTable, Address>),
    Address,
    PrefetchHooks Function()> {
  $$AddressesTableTableManager(_$DB db, $AddressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AddressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountUuid = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<int> index = const Value.absent(),
            Value<String?> encryptedPrivateKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AddressesCompanion(
            accountUuid: accountUuid,
            address: address,
            index: index,
            encryptedPrivateKey: encryptedPrivateKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountUuid,
            required String address,
            required int index,
            Value<String?> encryptedPrivateKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AddressesCompanion.insert(
            accountUuid: accountUuid,
            address: address,
            index: index,
            encryptedPrivateKey: encryptedPrivateKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AddressesTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $AddressesTable,
    Address,
    $$AddressesTableFilterComposer,
    $$AddressesTableOrderingComposer,
    $$AddressesTableAnnotationComposer,
    $$AddressesTableCreateCompanionBuilder,
    $$AddressesTableUpdateCompanionBuilder,
    (Address, BaseReferences<_$DB, $AddressesTable, Address>),
    Address,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String hash,
  required String raw,
  required String source,
  Value<String?> destination,
  Value<int?> btcAmount,
  Value<int?> fee,
  required String data,
  Value<String?> unpackedData,
  required DateTime submittedAt,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> hash,
  Value<String> raw,
  Value<String> source,
  Value<String?> destination,
  Value<int?> btcAmount,
  Value<int?> fee,
  Value<String> data,
  Value<String?> unpackedData,
  Value<DateTime> submittedAt,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$DB, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get raw => $composableBuilder(
      column: $table.raw, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get btcAmount => $composableBuilder(
      column: $table.btcAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unpackedData => $composableBuilder(
      column: $table.unpackedData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$DB, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raw => $composableBuilder(
      column: $table.raw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get btcAmount => $composableBuilder(
      column: $table.btcAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unpackedData => $composableBuilder(
      column: $table.unpackedData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$DB, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<int> get btcAmount =>
      $composableBuilder(column: $table.btcAmount, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get unpackedData => $composableBuilder(
      column: $table.unpackedData, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$DB,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, BaseReferences<_$DB, $TransactionsTable, Transaction>),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$DB db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> hash = const Value.absent(),
            Value<String> raw = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<int?> btcAmount = const Value.absent(),
            Value<int?> fee = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<String?> unpackedData = const Value.absent(),
            Value<DateTime> submittedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            hash: hash,
            raw: raw,
            source: source,
            destination: destination,
            btcAmount: btcAmount,
            fee: fee,
            data: data,
            unpackedData: unpackedData,
            submittedAt: submittedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String hash,
            required String raw,
            required String source,
            Value<String?> destination = const Value.absent(),
            Value<int?> btcAmount = const Value.absent(),
            Value<int?> fee = const Value.absent(),
            required String data,
            Value<String?> unpackedData = const Value.absent(),
            required DateTime submittedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            hash: hash,
            raw: raw,
            source: source,
            destination: destination,
            btcAmount: btcAmount,
            fee: fee,
            data: data,
            unpackedData: unpackedData,
            submittedAt: submittedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, BaseReferences<_$DB, $TransactionsTable, Transaction>),
    Transaction,
    PrefetchHooks Function()>;
typedef $$ImportedAddressesTableCreateCompanionBuilder
    = ImportedAddressesCompanion Function({
  required String address,
  required String encryptedWif,
  required String network,
  required String type_,
  Value<int> rowid,
});
typedef $$ImportedAddressesTableUpdateCompanionBuilder
    = ImportedAddressesCompanion Function({
  Value<String> address,
  Value<String> encryptedWif,
  Value<String> network,
  Value<String> type_,
  Value<int> rowid,
});

class $$ImportedAddressesTableFilterComposer
    extends Composer<_$DB, $ImportedAddressesTable> {
  $$ImportedAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedWif => $composableBuilder(
      column: $table.encryptedWif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type_ => $composableBuilder(
      column: $table.type_, builder: (column) => ColumnFilters(column));
}

class $$ImportedAddressesTableOrderingComposer
    extends Composer<_$DB, $ImportedAddressesTable> {
  $$ImportedAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedWif => $composableBuilder(
      column: $table.encryptedWif,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type_ => $composableBuilder(
      column: $table.type_, builder: (column) => ColumnOrderings(column));
}

class $$ImportedAddressesTableAnnotationComposer
    extends Composer<_$DB, $ImportedAddressesTable> {
  $$ImportedAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get encryptedWif => $composableBuilder(
      column: $table.encryptedWif, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get type_ =>
      $composableBuilder(column: $table.type_, builder: (column) => column);
}

class $$ImportedAddressesTableTableManager extends RootTableManager<
    _$DB,
    $ImportedAddressesTable,
    ImportedAddress,
    $$ImportedAddressesTableFilterComposer,
    $$ImportedAddressesTableOrderingComposer,
    $$ImportedAddressesTableAnnotationComposer,
    $$ImportedAddressesTableCreateCompanionBuilder,
    $$ImportedAddressesTableUpdateCompanionBuilder,
    (
      ImportedAddress,
      BaseReferences<_$DB, $ImportedAddressesTable, ImportedAddress>
    ),
    ImportedAddress,
    PrefetchHooks Function()> {
  $$ImportedAddressesTableTableManager(_$DB db, $ImportedAddressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedAddressesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> address = const Value.absent(),
            Value<String> encryptedWif = const Value.absent(),
            Value<String> network = const Value.absent(),
            Value<String> type_ = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImportedAddressesCompanion(
            address: address,
            encryptedWif: encryptedWif,
            network: network,
            type_: type_,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String address,
            required String encryptedWif,
            required String network,
            required String type_,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImportedAddressesCompanion.insert(
            address: address,
            encryptedWif: encryptedWif,
            network: network,
            type_: type_,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImportedAddressesTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $ImportedAddressesTable,
    ImportedAddress,
    $$ImportedAddressesTableFilterComposer,
    $$ImportedAddressesTableOrderingComposer,
    $$ImportedAddressesTableAnnotationComposer,
    $$ImportedAddressesTableCreateCompanionBuilder,
    $$ImportedAddressesTableUpdateCompanionBuilder,
    (
      ImportedAddress,
      BaseReferences<_$DB, $ImportedAddressesTable, ImportedAddress>
    ),
    ImportedAddress,
    PrefetchHooks Function()>;
typedef $$WalletConfigsTableCreateCompanionBuilder = WalletConfigsCompanion
    Function({
  required String uuid,
  required String network,
  required String basePath,
  required int accountIndexStart,
  required int accountIndexEnd,
  required String seedDerivation,
  Value<int> addrKindsMask,
  Value<int> rowid,
});
typedef $$WalletConfigsTableUpdateCompanionBuilder = WalletConfigsCompanion
    Function({
  Value<String> uuid,
  Value<String> network,
  Value<String> basePath,
  Value<int> accountIndexStart,
  Value<int> accountIndexEnd,
  Value<String> seedDerivation,
  Value<int> addrKindsMask,
  Value<int> rowid,
});

class $$WalletConfigsTableFilterComposer
    extends Composer<_$DB, $WalletConfigsTable> {
  $$WalletConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get basePath => $composableBuilder(
      column: $table.basePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountIndexStart => $composableBuilder(
      column: $table.accountIndexStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountIndexEnd => $composableBuilder(
      column: $table.accountIndexEnd,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seedDerivation => $composableBuilder(
      column: $table.seedDerivation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addrKindsMask => $composableBuilder(
      column: $table.addrKindsMask, builder: (column) => ColumnFilters(column));
}

class $$WalletConfigsTableOrderingComposer
    extends Composer<_$DB, $WalletConfigsTable> {
  $$WalletConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get basePath => $composableBuilder(
      column: $table.basePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountIndexStart => $composableBuilder(
      column: $table.accountIndexStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountIndexEnd => $composableBuilder(
      column: $table.accountIndexEnd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seedDerivation => $composableBuilder(
      column: $table.seedDerivation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addrKindsMask => $composableBuilder(
      column: $table.addrKindsMask,
      builder: (column) => ColumnOrderings(column));
}

class $$WalletConfigsTableAnnotationComposer
    extends Composer<_$DB, $WalletConfigsTable> {
  $$WalletConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get basePath =>
      $composableBuilder(column: $table.basePath, builder: (column) => column);

  GeneratedColumn<int> get accountIndexStart => $composableBuilder(
      column: $table.accountIndexStart, builder: (column) => column);

  GeneratedColumn<int> get accountIndexEnd => $composableBuilder(
      column: $table.accountIndexEnd, builder: (column) => column);

  GeneratedColumn<String> get seedDerivation => $composableBuilder(
      column: $table.seedDerivation, builder: (column) => column);

  GeneratedColumn<int> get addrKindsMask => $composableBuilder(
      column: $table.addrKindsMask, builder: (column) => column);
}

class $$WalletConfigsTableTableManager extends RootTableManager<
    _$DB,
    $WalletConfigsTable,
    WalletConfig,
    $$WalletConfigsTableFilterComposer,
    $$WalletConfigsTableOrderingComposer,
    $$WalletConfigsTableAnnotationComposer,
    $$WalletConfigsTableCreateCompanionBuilder,
    $$WalletConfigsTableUpdateCompanionBuilder,
    (WalletConfig, BaseReferences<_$DB, $WalletConfigsTable, WalletConfig>),
    WalletConfig,
    PrefetchHooks Function()> {
  $$WalletConfigsTableTableManager(_$DB db, $WalletConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> network = const Value.absent(),
            Value<String> basePath = const Value.absent(),
            Value<int> accountIndexStart = const Value.absent(),
            Value<int> accountIndexEnd = const Value.absent(),
            Value<String> seedDerivation = const Value.absent(),
            Value<int> addrKindsMask = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletConfigsCompanion(
            uuid: uuid,
            network: network,
            basePath: basePath,
            accountIndexStart: accountIndexStart,
            accountIndexEnd: accountIndexEnd,
            seedDerivation: seedDerivation,
            addrKindsMask: addrKindsMask,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String network,
            required String basePath,
            required int accountIndexStart,
            required int accountIndexEnd,
            required String seedDerivation,
            Value<int> addrKindsMask = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletConfigsCompanion.insert(
            uuid: uuid,
            network: network,
            basePath: basePath,
            accountIndexStart: accountIndexStart,
            accountIndexEnd: accountIndexEnd,
            seedDerivation: seedDerivation,
            addrKindsMask: addrKindsMask,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WalletConfigsTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $WalletConfigsTable,
    WalletConfig,
    $$WalletConfigsTableFilterComposer,
    $$WalletConfigsTableOrderingComposer,
    $$WalletConfigsTableAnnotationComposer,
    $$WalletConfigsTableCreateCompanionBuilder,
    $$WalletConfigsTableUpdateCompanionBuilder,
    (WalletConfig, BaseReferences<_$DB, $WalletConfigsTable, WalletConfig>),
    WalletConfig,
    PrefetchHooks Function()>;
typedef $$AccountConfigurationsTableCreateCompanionBuilder
    = AccountConfigurationsCompanion Function({
  required String walletUUID,
  required int index,
  required int addressIndex,
  Value<int> rowid,
});
typedef $$AccountConfigurationsTableUpdateCompanionBuilder
    = AccountConfigurationsCompanion Function({
  Value<String> walletUUID,
  Value<int> index,
  Value<int> addressIndex,
  Value<int> rowid,
});

class $$AccountConfigurationsTableFilterComposer
    extends Composer<_$DB, $AccountConfigurationsTable> {
  $$AccountConfigurationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get walletUUID => $composableBuilder(
      column: $table.walletUUID, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addressIndex => $composableBuilder(
      column: $table.addressIndex, builder: (column) => ColumnFilters(column));
}

class $$AccountConfigurationsTableOrderingComposer
    extends Composer<_$DB, $AccountConfigurationsTable> {
  $$AccountConfigurationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get walletUUID => $composableBuilder(
      column: $table.walletUUID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addressIndex => $composableBuilder(
      column: $table.addressIndex,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountConfigurationsTableAnnotationComposer
    extends Composer<_$DB, $AccountConfigurationsTable> {
  $$AccountConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get walletUUID => $composableBuilder(
      column: $table.walletUUID, builder: (column) => column);

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<int> get addressIndex => $composableBuilder(
      column: $table.addressIndex, builder: (column) => column);
}

class $$AccountConfigurationsTableTableManager extends RootTableManager<
    _$DB,
    $AccountConfigurationsTable,
    AccountConfiguration,
    $$AccountConfigurationsTableFilterComposer,
    $$AccountConfigurationsTableOrderingComposer,
    $$AccountConfigurationsTableAnnotationComposer,
    $$AccountConfigurationsTableCreateCompanionBuilder,
    $$AccountConfigurationsTableUpdateCompanionBuilder,
    (
      AccountConfiguration,
      BaseReferences<_$DB, $AccountConfigurationsTable, AccountConfiguration>
    ),
    AccountConfiguration,
    PrefetchHooks Function()> {
  $$AccountConfigurationsTableTableManager(
      _$DB db, $AccountConfigurationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountConfigurationsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountConfigurationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountConfigurationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> walletUUID = const Value.absent(),
            Value<int> index = const Value.absent(),
            Value<int> addressIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountConfigurationsCompanion(
            walletUUID: walletUUID,
            index: index,
            addressIndex: addressIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String walletUUID,
            required int index,
            required int addressIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountConfigurationsCompanion.insert(
            walletUUID: walletUUID,
            index: index,
            addressIndex: addressIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountConfigurationsTableProcessedTableManager
    = ProcessedTableManager<
        _$DB,
        $AccountConfigurationsTable,
        AccountConfiguration,
        $$AccountConfigurationsTableFilterComposer,
        $$AccountConfigurationsTableOrderingComposer,
        $$AccountConfigurationsTableAnnotationComposer,
        $$AccountConfigurationsTableCreateCompanionBuilder,
        $$AccountConfigurationsTableUpdateCompanionBuilder,
        (
          AccountConfiguration,
          BaseReferences<_$DB, $AccountConfigurationsTable,
              AccountConfiguration>
        ),
        AccountConfiguration,
        PrefetchHooks Function()>;
typedef $$UtxoAttachesTableCreateCompanionBuilder = UtxoAttachesCompanion
    Function({
  required DateTime createdAt,
  required String utxoID,
  required String asset,
  required bool divisible,
  required int quantity,
  Value<int> rowid,
});
typedef $$UtxoAttachesTableUpdateCompanionBuilder = UtxoAttachesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<String> utxoID,
  Value<String> asset,
  Value<bool> divisible,
  Value<int> quantity,
  Value<int> rowid,
});

class $$UtxoAttachesTableFilterComposer
    extends Composer<_$DB, $UtxoAttachesTable> {
  $$UtxoAttachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get utxoID => $composableBuilder(
      column: $table.utxoID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get asset => $composableBuilder(
      column: $table.asset, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get divisible => $composableBuilder(
      column: $table.divisible, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$UtxoAttachesTableOrderingComposer
    extends Composer<_$DB, $UtxoAttachesTable> {
  $$UtxoAttachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get utxoID => $composableBuilder(
      column: $table.utxoID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get asset => $composableBuilder(
      column: $table.asset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get divisible => $composableBuilder(
      column: $table.divisible, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$UtxoAttachesTableAnnotationComposer
    extends Composer<_$DB, $UtxoAttachesTable> {
  $$UtxoAttachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get utxoID =>
      $composableBuilder(column: $table.utxoID, builder: (column) => column);

  GeneratedColumn<String> get asset =>
      $composableBuilder(column: $table.asset, builder: (column) => column);

  GeneratedColumn<bool> get divisible =>
      $composableBuilder(column: $table.divisible, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$UtxoAttachesTableTableManager extends RootTableManager<
    _$DB,
    $UtxoAttachesTable,
    UtxoAttach,
    $$UtxoAttachesTableFilterComposer,
    $$UtxoAttachesTableOrderingComposer,
    $$UtxoAttachesTableAnnotationComposer,
    $$UtxoAttachesTableCreateCompanionBuilder,
    $$UtxoAttachesTableUpdateCompanionBuilder,
    (UtxoAttach, BaseReferences<_$DB, $UtxoAttachesTable, UtxoAttach>),
    UtxoAttach,
    PrefetchHooks Function()> {
  $$UtxoAttachesTableTableManager(_$DB db, $UtxoAttachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtxoAttachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtxoAttachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtxoAttachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> utxoID = const Value.absent(),
            Value<String> asset = const Value.absent(),
            Value<bool> divisible = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UtxoAttachesCompanion(
            createdAt: createdAt,
            utxoID: utxoID,
            asset: asset,
            divisible: divisible,
            quantity: quantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime createdAt,
            required String utxoID,
            required String asset,
            required bool divisible,
            required int quantity,
            Value<int> rowid = const Value.absent(),
          }) =>
              UtxoAttachesCompanion.insert(
            createdAt: createdAt,
            utxoID: utxoID,
            asset: asset,
            divisible: divisible,
            quantity: quantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UtxoAttachesTableProcessedTableManager = ProcessedTableManager<
    _$DB,
    $UtxoAttachesTable,
    UtxoAttach,
    $$UtxoAttachesTableFilterComposer,
    $$UtxoAttachesTableOrderingComposer,
    $$UtxoAttachesTableAnnotationComposer,
    $$UtxoAttachesTableCreateCompanionBuilder,
    $$UtxoAttachesTableUpdateCompanionBuilder,
    (UtxoAttach, BaseReferences<_$DB, $UtxoAttachesTable, UtxoAttach>),
    UtxoAttach,
    PrefetchHooks Function()>;

class $DBManager {
  final _$DB _db;
  $DBManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$AddressesTableTableManager get addresses =>
      $$AddressesTableTableManager(_db, _db.addresses);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ImportedAddressesTableTableManager get importedAddresses =>
      $$ImportedAddressesTableTableManager(_db, _db.importedAddresses);
  $$WalletConfigsTableTableManager get walletConfigs =>
      $$WalletConfigsTableTableManager(_db, _db.walletConfigs);
  $$AccountConfigurationsTableTableManager get accountConfigurations =>
      $$AccountConfigurationsTableTableManager(_db, _db.accountConfigurations);
  $$UtxoAttachesTableTableManager get utxoAttaches =>
      $$UtxoAttachesTableTableManager(_db, _db.utxoAttaches);
}
