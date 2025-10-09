import 'package:test/test.dart';
import 'package:path/path.dart' as p; // For handling file paths
import 'package:drift_dev/api/migrations.dart';
import "package:horizon/data/sources/local/db.dart";

import 'drift_migrations/schema.dart';
import 'dart:convert';
import 'dart:io' show File, Directory;
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';

import 'drift_migrations/schema_v6.dart' as v6;
import 'drift_migrations/schema_v7.dart' as v7;

const bool kVerbose = true;

void _log(String msg) {
  if (kVerbose) {
    // always print
    // ignore: avoid_print
    print(msg);
  } else {
    // only show if a test fails
    printOnFailure(msg);
  }
}

Fixture loadFixtureFromFile(String path_) {
  final path = p.join(Directory.current.path, path_);
  final raw = File(path).readAsStringSync();
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return Fixture.fromJson(map);
}

// ---------- Models ----------

class Fixture {
  final List<FixtureCase> cases;

  Fixture({required this.cases});

  factory Fixture.fromJson(Map<String, dynamic> json) {
    final list = (json['cases'] as List<dynamic>? ?? const []);
    return Fixture(
      cases: list
          .map((e) => FixtureCase.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cases': cases.map((e) => e.toJson()).toList(),
      };
}

class FixtureCase {
  final String format;
  final String mnemonic;
  final DbSnapshot db;

  FixtureCase({
    required this.format,
    required this.mnemonic,
    required this.db,
  });

  factory FixtureCase.fromJson(Map<String, dynamic> json) => FixtureCase(
        format: json['format'] as String,
        mnemonic: json['mnemonic'] as String,
        db: DbSnapshot.fromJson(json['db'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'format': format,
        'mnemonic': mnemonic,
        'db': db.toJson(),
      };
}

class DbSnapshot {
  final List<WalletRow> wallets;
  final List<AccountRow> accounts;
  final List<AddressRow> addresses;
  final List<dynamic> transactions; // Keeping dynamic since your fixture has []
  final List<ImportedAddressRow> importedAddresses;

  DbSnapshot({
    required this.wallets,
    required this.accounts,
    required this.addresses,
    required this.transactions,
    required this.importedAddresses,
  });

  factory DbSnapshot.fromJson(Map<String, dynamic> json) => DbSnapshot(
        wallets: ((json['wallets'] as List<dynamic>? ?? const []))
            .map((e) => WalletRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        accounts: ((json['accounts'] as List<dynamic>? ?? const []))
            .map((e) => AccountRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        addresses: ((json['addresses'] as List<dynamic>? ?? const []))
            .map((e) => AddressRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: (json['transactions'] as List<dynamic>? ?? const []),
        importedAddresses: ((json['imported_addresses'] as List<dynamic>? ??
                const []))
            .map((e) => ImportedAddressRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'wallets': wallets.map((e) => e.toJson()).toList(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'addresses': addresses.map((e) => e.toJson()).toList(),
        'transactions': transactions,
        'imported_addresses': importedAddresses.map((e) => e.toJson()).toList(),
      };
}

class WalletRow {
  final String uuid;
  final String name;
  final String encryptedPrivKey;
  final String encryptedMnemonic;
  final String publicKey;
  final String chainCodeHex;

  WalletRow({
    required this.uuid,
    required this.name,
    required this.encryptedPrivKey,
    required this.encryptedMnemonic,
    required this.publicKey,
    required this.chainCodeHex,
  });

  factory WalletRow.fromJson(Map<String, dynamic> json) => WalletRow(
        uuid: json['uuid'] as String,
        name: json['name'] as String,
        encryptedPrivKey: json['encrypted_priv_key'] as String,
        encryptedMnemonic: json['encrypted_mnemonic'] as String,
        publicKey: json['public_key'] as String,
        chainCodeHex: json['chain_code_hex'] as String,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'encrypted_priv_key': encryptedPrivKey,
        'encrypted_mnemonic': encryptedMnemonic,
        'public_key': publicKey,
        'chain_code_hex': chainCodeHex,
      };
}

class AccountRow {
  final String uuid;
  final String name;
  final String walletUuid;

  /// Kept as String because your fixture mixes "0" and "0'".
  final String purpose;
  final String coinType;
  final String accountIndex;
  final String importFormat;

  AccountRow({
    required this.uuid,
    required this.name,
    required this.walletUuid,
    required this.purpose,
    required this.coinType,
    required this.accountIndex,
    required this.importFormat,
  });

  factory AccountRow.fromJson(Map<String, dynamic> json) => AccountRow(
        uuid: json['uuid'] as String,
        name: json['name'] as String,
        walletUuid: json['wallet_uuid'] as String,
        purpose: json['purpose'] as String,
        coinType: json['coin_type'] as String,
        accountIndex: json['account_index'] as String,
        importFormat: json['import_format'] as String,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'wallet_uuid': walletUuid,
        'purpose': purpose,
        'coin_type': coinType,
        'account_index': accountIndex,
        'import_format': importFormat,
      };
}

class AddressRow {
  final String accountUuid;
  final String address;
  final int index;
  final String? encryptedPrivateKey;

  AddressRow({
    required this.accountUuid,
    required this.address,
    required this.index,
    required this.encryptedPrivateKey,
  });

  factory AddressRow.fromJson(Map<String, dynamic> json) => AddressRow(
        accountUuid: json['account_uuid'] as String,
        address: json['address'] as String,
        index: (json['index'] as num).toInt(),
        encryptedPrivateKey: json['encrypted_private_key'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'account_uuid': accountUuid,
        'address': address,
        'index': index,
        'encrypted_private_key': encryptedPrivateKey,
      };
}

class ImportedAddressRow {
  final String address;
  final String name;
  final String encryptedWif;

  ImportedAddressRow({
    required this.address,
    required this.name,
    required this.encryptedWif,
  });

  factory ImportedAddressRow.fromJson(Map<String, dynamic> json) =>
      ImportedAddressRow(
        address: json['address'] as String,
        name: json['name'] as String,
        encryptedWif: json['encrypted_wif'] as String,
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'name': name,
        'encrypted_wif': encryptedWif,
      };
}

void main() {
  Future<void> seedV6(v6.DatabaseAtV6 db, FixtureCase c) async {
    await db.transaction(() async {
      // wallets
      if (c.db.wallets.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
            db.wallets,
            c.db.wallets
                .map((w) => RawValuesInsertable({
                      'uuid': Variable(w.uuid),
                      'name': Variable(w.name),
                      'encrypted_priv_key': Variable(w.encryptedPrivKey),
                      'encrypted_mnemonic': Variable(w.encryptedMnemonic),
                      'public_key': Variable(w.publicKey),
                      'chain_code_hex': Variable(w.chainCodeHex),
                    }))
                .toList(),
          );
        });
      }

      // accounts
      if (c.db.accounts.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
            db.accounts,
            c.db.accounts
                .map((a) => RawValuesInsertable({
                      'uuid': Variable(a.uuid),
                      'name': Variable(a.name),
                      'wallet_uuid': Variable(a.walletUuid),
                      'purpose': Variable(a.purpose), // TEXT in v6
                      'coin_type': Variable(a.coinType), // TEXT in v6
                      'account_index': Variable(a.accountIndex), // TEXT in v6
                      'import_format': Variable(a.importFormat),
                    }))
                .toList(),
          );
        });
      }

      // addresses
      if (c.db.addresses.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
              db.addresses,
              c.db.addresses
                  .map((addr) => RawValuesInsertable({
                        'account_uuid': Variable(addr.accountUuid),
                        'address': Variable(addr.address),
                        'index': Variable(addr.index),
                      }))
                  .toList());
        });
      }

      // imported_addresses
      if (c.db.importedAddresses.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
            db.importedAddresses,
            c.db.importedAddresses
                .map((ia) => RawValuesInsertable({
                      'address': Variable(ia.address),
                      'name': Variable(ia.name),
                      'encrypted_wif': Variable(ia.encryptedWif),
                    }))
                .toList(),
          );
        });
      }
    });
  }

  String _expectedType(String addr) {
    if (addr.startsWith('bc1q') || addr.startsWith('tb1q')) {
      return 'p2wpkh';
    }
    if (addr.startsWith('1') || addr.startsWith('m') || addr.startsWith('n')) {
      return 'p2pkh';
    }
    return 'p2wpkh';
  }

  Future<void> _dumpTable(v7.DatabaseAtV7 db, String table,
      {String? orderBy, int limit = 9999}) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM $table${orderBy != null ? ' ORDER BY $orderBy' : ''} LIMIT $limit',
        )
        .get();

    _log('── $table (${rows.length} row${rows.length == 1 ? '' : 's'})');
    for (final r in rows) {
      _log('  ${r.data}');
    }
  }

  group('fixtures: v6 -> v7', () {
    late SchemaVerifier verifier;
    late Fixture fixture;

    verifier = SchemaVerifier(GeneratedHelper());
    const fixturePath = 'test/fixtures/schema_v6_db_dumps.json';
    fixture = loadFixtureFromFile(fixturePath);

    for (var i = 0; i < fixture.cases.length; i++) {
      final c = fixture.cases[i];
      final testName = '[${i + 1}/${fixture.cases.length}] ${c.format}';
      test(testName, () async {
        _log("\n\n\n test case: $testName");
        final schema = await verifier.schemaAt(6);

        // 1) seed v6
        final oldDb = v6.DatabaseAtV6(schema.newConnection());
        _log('→ seeding v6 for case: ${c.format} '
            '(wallets=${c.db.wallets.length}, accounts=${c.db.accounts.length}, '
            'addresses=${c.db.addresses.length}, imported=${c.db.importedAddresses.length})');
        await seedV6(oldDb, c);
        await oldDb.close();

        // 2) migrate & validate to v7 using current DB
        _log('→ migrate & validate to v7');
        final currentDb = DB(schema.newConnection());
        await verifier.migrateAndValidate(currentDb, 7);
        await currentDb.close();

        // 3) open v7 snapshot and assert expectations
        final migratedDb = v7.DatabaseAtV7(schema.newConnection());
        try {
          _log('→ post-migration dumps:');
          await _dumpTable(migratedDb, 'imported_addresses',
              orderBy: 'address');
          await _dumpTable(migratedDb, 'wallet_configs');
          // optional: keep these handy while iterating
          // await _dumpTable(migratedDb, 'accounts', orderBy: 'wallet_uuid, account_index');
          // await _dumpSchema(migratedDb);

          _log("\n\nassertions:");
          // imported_addresses: ensure rebuild with expected network/type
          final iaRows = await migratedDb
              .customSelect(
                  'SELECT address, encrypted_wif, network, type FROM imported_addresses ORDER BY address')
              .get();

          final expectedIA = c.db.importedAddresses
              .where((ia) => ia.encryptedWif.isNotEmpty) // non-null WIFs only
              .toList()
            ..sort((a, b) => a.address.compareTo(b.address));

          _log(
              '→ asserting imported_addresses: actual=${iaRows.length}, expected=${expectedIA.length}');
          expect(iaRows.length, expectedIA.length,
              reason:
                  '[${c.format}] imported_addresses row count mismatch after migration');

          for (var j = 0; j < expectedIA.length; j++) {
            final row = iaRows[j].data;
            final exp = expectedIA[j];
            _log('  cmp[$j] '
                'addr=${row['address']} == ${exp.address} | '
                'wif==${row['encrypted_wif'] == exp.encryptedWif} | '
                'net=${row['network']} exp=mainnet} | '
                'type=${row['type']} exp=${_expectedType(exp.address)}');

            expect(row['address'], exp.address);
            expect(row['encrypted_wif'], exp.encryptedWif);
            // if you know all current fixtures are mainnet, you can keep it hard-coded.
            // otherwise use computed expectation:
            expect(row['network'], "mainnet");
            expect(row['type'], _expectedType(exp.address));
          }

          // wallet_configs: one row inserted (LIMIT 1) with computed fields
          final wcRows = await migratedDb
              .customSelect(
                  'SELECT uuid, network, base_path, account_index_start, account_index_end, seed_derivation, addr_kinds_mask FROM wallet_configs')
              .get();
          _log('→ asserting wallet_configs: rows=${wcRows.length}');
          expect(wcRows.length, 1,
              reason: '[${c.format}] wallet_configs should have 1 row');

          final wc = wcRows.single.data;

          // detect formats (lowercased)
          final hasHorizon = c.db.accounts
              .any((a) => a.importFormat.toLowerCase() == 'horizon');
          final hasCounter = c.db.accounts
              .any((a) => a.importFormat.toLowerCase() == 'counterwallet');
          final hasFree = c.db.accounts
              .any((a) => a.importFormat.toLowerCase() == 'freewallet');

          final expectedBasePath = hasHorizon
              ? "m/84'/0'/|m/84'/1'/" // matches your SQL intent
              : (hasCounter || hasFree)
                  ? 'm/|m/'
                  : 'm/|m/';
          final expectedSeed = hasHorizon
              ? 'bip39MnemonicToSeed'
              : hasCounter
                  ? 'mnemonicJSToHex'
                  : hasFree
                      ? 'bip39MnemonicToEntropy'
                      : 'bip39MnemonicToSeed';
          final expectedMask = hasHorizon ? 2 : 3;

          // simplified expectation from your snippet
          final expectedStart = 0;
          final expectedEnd = c.db.accounts.length - 1;

          _log('  wallet_configs row: $wc');
          _log('  expected: {uuid:${c.db.wallets.single.uuid}, '
              'network:mainnet, base_path:$expectedBasePath, '
              'seed:$expectedSeed, mask:$expectedMask, '
              'start:$expectedStart, end:$expectedEnd}');

          expect(wc['network'], 'mainnet',
              reason: '[${c.format}] wallet_configs.network');
          expect(wc['base_path'], expectedBasePath,
              reason: '[${c.format}] wallet_configs.base_path');
          expect(wc['seed_derivation'], expectedSeed,
              reason: '[${c.format}] wallet_configs.seed_derivation');
          expect(wc['addr_kinds_mask'], expectedMask,
              reason: '[${c.format}] wallet_configs.addr_kinds_mask');
          expect(wc['account_index_start'], expectedStart,
              reason: '[${c.format}] wallet_configs.account_index_start');
          expect(wc['account_index_end'], expectedEnd,
              reason: '[${c.format}] wallet_configs.account_index_end');

          // optional: old table still exists while undecided
          final oldTable = await migratedDb
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='imported_addresses_old'",
              )
              .get();
          _log('→ imported_addresses_old present: ${oldTable.isNotEmpty}');
          expect(oldTable.length, 1,
              reason:
                  '[${c.format}] imported_addresses_old should still exist (not dropped)');
        } finally {
          await migratedDb.close();
        }
      });
    }
  });
}
