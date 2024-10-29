// import 'dart:js' as js;

import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';
import 'package:horizon/data/sources/local/tables/imported_addresses_table.dart';
import "package:horizon/data/sources/local/tables/wallets_table.dart";
import "package:horizon/data/sources/local/tables/transactions_table.dart";
import 'schema_versions.dart';

part "db.g.dart";

// TODO: read from env
const ENV = "dev";

@DriftDatabase(
    tables: [Wallets, Accounts, Addresses, Transactions, ImportedAddresses])
class DB extends _$DB {
  DB(super.e);

  @override
  int get schemaVersion => 5;

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
            steps: migrationSteps(
              from1To2: (m, schema) async {
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
              },
              from2To3: (m, schema) async {
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
                    schema.transactions.fee:
                        schema.transactions.fee.cast<int>(),
                    schema.transactions.unpackedData:
                        schema.transactions.unpackedData.cast<String>()
                  },
                ));
              },
              from3To4: (m, schema) async {
                // Add the new column to the Addresses table
                await m.addColumn(
                    schema.addresses, schema.addresses.encryptedPrivateKey);

                // Create the new ImportedAddresses table
                await m.createTable(schema.importedAddresses);
              },
              from4To5: (m, schema) async {
                // Create temporary table with new structure
                await customStatement('''
                  CREATE TABLE imported_addresses_temp (
                    address TEXT NOT NULL UNIQUE,
                    name TEXT NOT NULL DEFAULT '',
                    encrypted_private_key TEXT NOT NULL UNIQUE,
                    wallet_uuid TEXT NOT NULL,
                    PRIMARY KEY (address)
                  );

                  -- Copy data from old table to new table
                  INSERT INTO imported_addresses_temp (address, encrypted_private_key, wallet_uuid)
                  SELECT address, encrypted_private_key, wallet_uuid
                  FROM imported_addresses;

                  -- Drop old table
                  DROP TABLE imported_addresses;

                  -- Rename temp table to final name
                  ALTER TABLE imported_addresses_temp RENAME TO imported_addresses;
                ''');
              },
            ));

        if (ENV == "dev") {
          final wrongForeignKeys =
              await customSelect('PRAGMA foreign_key_check').get();
          assert(wrongForeignKeys.isEmpty,
              '${wrongForeignKeys.map((e) => e.data)}');
        }

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
