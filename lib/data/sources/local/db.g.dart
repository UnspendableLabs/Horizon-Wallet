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
  static const VerificationMeta _wifMeta = const VerificationMeta('wif');
  @override
  late final GeneratedColumn<String> wif = GeneratedColumn<String>(
      'wif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, name, wif];
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
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
  final String name;
  final String wif;
  const Wallet({required this.uuid, required this.name, required this.wif});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wif'] = Variable<String>(wif);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      wif: Value(wif),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      wif: serializer.fromJson<String>(json['wif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'wif': serializer.toJson<String>(wif),
    };
  }

  Wallet copyWith({String? uuid, String? name, String? wif}) => Wallet(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        wif: wif ?? this.wif,
      );
  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('wif: $wif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, wif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.wif == this.wif);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> wif;
  final Value<int> rowid;
  const WalletsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.wif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String uuid,
    required String name,
    required String wif,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        wif = Value(wif);
  static Insertable<Wallet> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? wif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (wif != null) 'wif': wif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? wif,
      Value<int>? rowid}) {
    return WalletsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('name: $name, ')
          ..write('wif: $wif, ')
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
  late final GeneratedColumn<int> coinType = GeneratedColumn<int>(
      'coin_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
      [uuid, name, walletUuid, purpose, coinType, accountIndex, xPub];
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
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      coinType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coin_type'])!,
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
  final String purpose;
  final int coinType;
  final int accountIndex;
  final String xPub;
  const Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.purpose,
      required this.coinType,
      required this.accountIndex,
      required this.xPub});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['wallet_uuid'] = Variable<String>(walletUuid);
    map['purpose'] = Variable<String>(purpose);
    map['coin_type'] = Variable<int>(coinType);
    map['account_index'] = Variable<int>(accountIndex);
    map['x_pub'] = Variable<String>(xPub);
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
      purpose: serializer.fromJson<String>(json['purpose']),
      coinType: serializer.fromJson<int>(json['coinType']),
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
      'purpose': serializer.toJson<String>(purpose),
      'coinType': serializer.toJson<int>(coinType),
      'accountIndex': serializer.toJson<int>(accountIndex),
      'xPub': serializer.toJson<String>(xPub),
    };
  }

  Account copyWith(
          {String? uuid,
          String? name,
          String? walletUuid,
          String? purpose,
          int? coinType,
          int? accountIndex,
          String? xPub}) =>
      Account(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        walletUuid: walletUuid ?? this.walletUuid,
        purpose: purpose ?? this.purpose,
        coinType: coinType ?? this.coinType,
        accountIndex: accountIndex ?? this.accountIndex,
        xPub: xPub ?? this.xPub,
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
          ..write('xPub: $xPub')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, name, walletUuid, purpose, coinType, accountIndex, xPub);
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
          other.xPub == this.xPub);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> walletUuid;
  final Value<String> purpose;
  final Value<int> coinType;
  final Value<int> accountIndex;
  final Value<String> xPub;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.walletUuid = const Value.absent(),
    this.purpose = const Value.absent(),
    this.coinType = const Value.absent(),
    this.accountIndex = const Value.absent(),
    this.xPub = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    required String name,
    required String walletUuid,
    required String purpose,
    required int coinType,
    required int accountIndex,
    required String xPub,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        walletUuid = Value(walletUuid),
        purpose = Value(purpose),
        coinType = Value(coinType),
        accountIndex = Value(accountIndex),
        xPub = Value(xPub);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? walletUuid,
    Expression<String>? purpose,
    Expression<int>? coinType,
    Expression<int>? accountIndex,
    Expression<String>? xPub,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (walletUuid != null) 'wallet_uuid': walletUuid,
      if (purpose != null) 'purpose': purpose,
      if (coinType != null) 'coin_type': coinType,
      if (accountIndex != null) 'account_index': accountIndex,
      if (xPub != null) 'x_pub': xPub,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? walletUuid,
      Value<String>? purpose,
      Value<int>? coinType,
      Value<int>? accountIndex,
      Value<String>? xPub,
      Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      walletUuid: walletUuid ?? this.walletUuid,
      purpose: purpose ?? this.purpose,
      coinType: coinType ?? this.coinType,
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
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (coinType.present) {
      map['coin_type'] = Variable<int>(coinType.value);
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
          ..write('purpose: $purpose, ')
          ..write('coinType: $coinType, ')
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
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wallets, accounts, addresses];
}
