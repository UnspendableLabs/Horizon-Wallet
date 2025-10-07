// import 'dart:js' as js;

import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';
import 'package:horizon/data/sources/local/tables/imported_addresses_table.dart';
import "package:horizon/data/sources/local/tables/wallets_table.dart";
import "package:horizon/data/sources/local/tables/wallet_configs_table.dart";
import "package:horizon/data/sources/local/tables/transactions_table.dart";
import "package:horizon/data/sources/local/tables/account_configurations_table.dart";
import "package:horizon/data/sources/local/tables/utxo_attaches_table.dart";
import 'schema_versions.dart';

part "db.g.dart";

// TODO: accounts migration

// TODO: read from env

@DriftDatabase(tables: [
  Wallets,
  Accounts,
  Addresses,
  Transactions,
  ImportedAddresses,
  WalletConfigs,
  AccountConfigurations,
  UtxoAttaches
])
class DB extends _$DB {
  DB(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Run migration steps without foreign keys and re-enable them later
        // (https://drift.simonbinder.eu/docs/advanced-features/migrations/#tips)

        await customStatement('PRAGMA foreign_keys = OFF');

        await m.runMigrationSteps(
            from: from,
            to: to,
            steps: migrationSteps(from1To2: (m, schema) async {
              await m.createTable(schema.transactions);

              // migrate addresses table

              // step 1) migrate primary key
              await customStatement('''
                      -- Create a new table with the desired structure
                      CREATE TABLE addresses_temp (
                        account_uuid TEXT NOT NULL,
                        address TEXT NOT NULL UNIQUE,
                        address_index INTEGER NOT NULL,
                        PRIMARY KEY (address)
                      );

                      -- Copy data from the old table to the new one
                      INSERT INTO addresses_temp (account_uuid, address, address_index)
                      SELECT account_uuid, address, "index" FROM addresses;

                      -- Drop the old table
                      DROP TABLE addresses;

                      -- Rename the new table to the original name
                      ALTER TABLE addresses_temp RENAME TO addresses;
                ''');

              // step 2) rename column `address_index` to `index

              await m.alterTable(TableMigration(
                schema.addresses,
                columnTransformer: {
                  schema.addresses.index:
                      const CustomExpression('address_index')
                },
              ));
            }, from2To3: (m, schema) async {
              // add encryptedMnemonic column to wallets table
              await m.addColumn(
                  schema.wallets, schema.wallets.encryptedMnemonic);

              // // make btc_amount, fee, and unpacked_data nullable
              // https://drift.simonbinder.eu/docs/migrations/api/#changing-the-type-of-a-column
              await m.alterTable(TableMigration(
                schema.transactions,
                columnTransformer: {
                  schema.transactions.btcAmount:
                      schema.transactions.btcAmount.cast<int>(),
                  schema.transactions.fee: schema.transactions.fee.cast<int>(),
                  schema.transactions.unpackedData:
                      schema.transactions.unpackedData.cast<String>()
                },
              ));
            }, from3To4: (m, schema) async {
              // Add the new column to the Addresses table
              await m.addColumn(
                  schema.addresses, schema.addresses.encryptedPrivateKey);

              // Create the new ImportedAddresses table
              await m.createTable(schema.importedAddresses);
            }, from4To5: (m, schema) async {
              // Create temporary table with new structure
              await customStatement('''
                  CREATE TABLE imported_addresses_temp (
                    address TEXT NOT NULL UNIQUE,
                    name TEXT NOT NULL DEFAULT '',
                    encrypted_wif TEXT NOT NULL UNIQUE,
                    wallet_uuid TEXT NOT NULL,
                    PRIMARY KEY (address)
                  );

                  -- Copy data from old table to new table, renaming column
                  INSERT INTO imported_addresses_temp (address, name, encrypted_wif, wallet_uuid)
                  SELECT address, '', encrypted_private_key, wallet_uuid
                  FROM imported_addresses;

                  -- Drop old table
                  DROP TABLE imported_addresses;

                  -- Rename temp table to final name
                  ALTER TABLE imported_addresses_temp RENAME TO imported_addresses;
                ''');
            }, from5To6: (m, schema) async {
              // Create temporary table without wallet_uuid
              await customStatement('''



                  CREATE TABLE imported_addresses_temp (
                    address TEXT NOT NULL UNIQUE,
                    name TEXT NOT NULL DEFAULT '',
                    encrypted_wif TEXT NOT NULL UNIQUE,
                    PRIMARY KEY (address)
                  );

                  -- Copy data from old table to new table, excluding wallet_uuid
                  INSERT INTO imported_addresses_temp (address, name, encrypted_wif)
                  SELECT address, name, encrypted_wif
                  FROM imported_addresses;

                  -- Drop old table
                  DROP TABLE imported_addresses;

                  -- Rename temp table to final name
                  ALTER TABLE imported_addresses_temp RENAME TO imported_addresses;
                ''');
            }, from6To7: (m, schema) async {
              await customStatement(
                  "ALTER TABLE imported_addresses RENAME TO imported_addresses_old");

              await customStatement('''
    CREATE TABLE imported_addresses (
      address TEXT NOT NULL UNIQUE,
      encrypted_wif TEXT NOT NULL,
      network       TEXT NOT NULL,
      type         TEXT NOT NULL,
      PRIMARY KEY (address)
    )
  ''');

              await customStatement('''
    INSERT INTO imported_addresses (address, encrypted_wif, network, type)
    SELECT
      ia_old.address,
      ia_old.encrypted_wif,
      CASE
        WHEN ia_old.address GLOB 'bc1*' OR ia_old.address GLOB '1*'            THEN 'mainnet'
        WHEN ia_old.address GLOB 'tb1*' OR ia_old.address GLOB 'm*' OR ia_old.address GLOB 'n*' THEN 'testnet4'
        ELSE 'mainnet'
      END AS network,
      CASE
        WHEN ia_old.address GLOB 'bc1q*' OR ia_old.address GLOB 'tb1q*' THEN 'p2wpkh'
        WHEN ia_old.address GLOB '1*'    OR ia_old.address GLOB 'm*'   OR ia_old.address GLOB 'n*' THEN 'p2pkh'
        ELSE 'p2wpkh'
      END AS type
    FROM imported_addresses_old AS ia_old
    WHERE ia_old.encrypted_wif IS NOT NULL
  ''');

              // TODO: decide whether or not to keep old table:
              // await customStatement('DROP TABLE imported_addresses_old');

              m.createTable(schema.walletConfigs);

              await customStatement('''
    WITH per_wallet AS (
      SELECT
        w.uuid AS wallet_uuid,
        SUM(CASE LOWER(a.import_format) WHEN 'horizon'       THEN 1 ELSE 0 END) AS has_horizon,
        SUM(CASE LOWER(a.import_format) WHEN 'counterwallet' THEN 1 ELSE 0 END) AS has_counterwallet,
        SUM(CASE LOWER(a.import_format) WHEN 'freewallet'    THEN 1 ELSE 0 END) AS has_freewallet,
        MIN(CASE WHEN a.account_index GLOB '[0-9]*' THEN CAST(a.account_index AS INTEGER) END) AS min_idx,
        MAX(CASE WHEN a.account_index GLOB '[0-9]*' THEN CAST(a.account_index AS INTEGER) END) AS max_idx
      FROM wallets w
      JOIN accounts a ON a.wallet_uuid = w.uuid
      GROUP BY w.uuid
    )
    INSERT OR IGNORE INTO wallet_configs (
      uuid, network, base_path, account_index_start, account_index_end, seed_derivation, addr_kinds_mask
    )
    SELECT
      pw.wallet_uuid                    AS uuid,
      'mainnet'                         AS network,
      CASE
        WHEN pw.has_horizon       > 0 THEN 'm/84''/0''/|m/84''/1''/'
        WHEN pw.has_counterwallet > 0 THEN 'm/|m/'
        WHEN pw.has_freewallet    > 0 THEN 'm/|m/'
        ELSE 'm/|m/'
      END                                 AS base_path,
      COALESCE(pw.min_idx, 0)             AS account_index_start,
      COALESCE(pw.max_idx, 0)             AS account_index_end,
      CASE
        WHEN pw.has_horizon       > 0 THEN 'bip39MnemonicToSeed'
        WHEN pw.has_counterwallet > 0 THEN 'mnemonicJSToHex'
        WHEN pw.has_freewallet    > 0 THEN 'bip39MnemonicToEntropy'
        ELSE 'bip39MnemonicToSeed'
      END                                 AS seed_derivation,
      CASE
	WHEN pw.has_horizon       > 0 THEN 2       -- p2wpkh only
	WHEN pw.has_counterwallet > 0 THEN 3       -- p2pkh | p2wpkh
	WHEN pw.has_freewallet    > 0 THEN 3       -- p2pkh | p2wpkh
	ELSE 2                                     -- default p2wpkh
      END                               AS addr_kinds_mask
    FROM per_wallet pw
    LIMIT 1;
  ''');

              m.createTable(schema.accountConfigurations);
            }));

        // if (ENV == "dev") {
        //   final wrongForeignKeys =
        //       await customSelect('PRAGMA foreign_key_check').get();
        //   assert(wrongForeignKeys.isEmpty,
        //       '${wrongForeignKeys.map((e) => e.data)}');
        // }
        //
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  // Method to reset the database
  Future<void> resetDatabase() async {
    await close(); // Close the existing database connection
    // Reinitialize the database connection
    // Optionally, you can re-run the onCreate methods if needed
    markTablesUpdated(allTables);
  }

  // Future<void> deleteDatabase() async {
  //   await close(); // Ensure the database is closed before deleting
  //
  //   // JavaScript code to delete IndexedDB
  //   js.context.callMethod('eval', [
  //     """
  //     var DBDeleteRequest = window.indexedDB.deleteDatabase('horizon_db');
  //
  //     DBDeleteRequest.onerror = function(event) {
  //       console.log('Error deleting database.');
  //     };
  //
  //     DBDeleteRequest.onsuccess = function(event) {
  //       console.log('Database deleted successfully');
  //     };
  //   """
  //   ]);
  //
  //   print('Database deletion initiated');
  // }
}
