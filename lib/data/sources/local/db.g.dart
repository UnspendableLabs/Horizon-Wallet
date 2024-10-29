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
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encryptedWIFMeta =
      const VerificationMeta('encryptedWIF');
  @override
  late final GeneratedColumn<String> encryptedWIF = GeneratedColumn<String>(
      'encrypted_w_i_f', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [address, name, encryptedWIF];
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('encrypted_w_i_f')) {
      context.handle(
          _encryptedWIFMeta,
          encryptedWIF.isAcceptableOrUnknown(
              data['encrypted_w_i_f']!, _encryptedWIFMeta));
    } else if (isInserting) {
      context.missing(_encryptedWIFMeta);
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      encryptedWIF: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_w_i_f'])!,
    );
  }

  @override
  $ImportedAddressesTable createAlias(String alias) {
    return $ImportedAddressesTable(attachedDatabase, alias);
  }
}

class ImportedAddress extends DataClass implements Insertable<ImportedAddress> {
  final String address;
  final String name;
  final String encryptedWIF;
  const ImportedAddress(
      {required this.address, required this.name, required this.encryptedWIF});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['address'] = Variable<String>(address);
    map['name'] = Variable<String>(name);
    map['encrypted_w_i_f'] = Variable<String>(encryptedWIF);
    return map;
  }

  ImportedAddressesCompanion toCompanion(bool nullToAbsent) {
    return ImportedAddressesCompanion(
      address: Value(address),
      name: Value(name),
      encryptedWIF: Value(encryptedWIF),
    );
  }

  factory ImportedAddress.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedAddress(
      address: serializer.fromJson<String>(json['address']),
      name: serializer.fromJson<String>(json['name']),
      encryptedWIF: serializer.fromJson<String>(json['encryptedWIF']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'address': serializer.toJson<String>(address),
      'name': serializer.toJson<String>(name),
      'encryptedWIF': serializer.toJson<String>(encryptedWIF),
    };
  }

  ImportedAddress copyWith(
          {String? address, String? name, String? encryptedWIF}) =>
      ImportedAddress(
        address: address ?? this.address,
        name: name ?? this.name,
        encryptedWIF: encryptedWIF ?? this.encryptedWIF,
      );
  @override
  String toString() {
    return (StringBuffer('ImportedAddress(')
          ..write('address: $address, ')
          ..write('name: $name, ')
          ..write('encryptedWIF: $encryptedWIF')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(address, name, encryptedWIF);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedAddress &&
          other.address == this.address &&
          other.name == this.name &&
          other.encryptedWIF == this.encryptedWIF);
}

class ImportedAddressesCompanion extends UpdateCompanion<ImportedAddress> {
  final Value<String> address;
  final Value<String> name;
  final Value<String> encryptedWIF;
  final Value<int> rowid;
  const ImportedAddressesCompanion({
    this.address = const Value.absent(),
    this.name = const Value.absent(),
    this.encryptedWIF = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedAddressesCompanion.insert({
    required String address,
    required String name,
    required String encryptedWIF,
    this.rowid = const Value.absent(),
  })  : address = Value(address),
        name = Value(name),
        encryptedWIF = Value(encryptedWIF);
  static Insertable<ImportedAddress> custom({
    Expression<String>? address,
    Expression<String>? name,
    Expression<String>? encryptedWIF,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'address': address,
      if (name != null) 'name': name,
      if (encryptedWIF != null) 'encrypted_w_i_f': encryptedWIF,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedAddressesCompanion copyWith(
      {Value<String>? address,
      Value<String>? name,
      Value<String>? encryptedWIF,
      Value<int>? rowid}) {
    return ImportedAddressesCompanion(
      address: address ?? this.address,
      name: name ?? this.name,
      encryptedWIF: encryptedWIF ?? this.encryptedWIF,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (encryptedWIF.present) {
      map['encrypted_w_i_f'] = Variable<String>(encryptedWIF.value);
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
          ..write('name: $name, ')
          ..write('encryptedWIF: $encryptedWIF, ')
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
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ImportedAddressesTable importedAddresses =
      $ImportedAddressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wallets, accounts, addresses, transactions, importedAddresses];
}
