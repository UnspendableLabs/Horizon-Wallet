import 'dart:js' as js;

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';
import "package:horizon/data/sources/local/tables/wallets_table.dart";
import "package:horizon/data/sources/local/tables/transactions_table.dart";
import 'schema_versions.dart';

part "db.g.dart";

// TODO: read from env
final ENV = "dev";

@DriftDatabase(tables: [Wallets, Accounts, Addresses, Transactions])
class DB extends _$DB {
  DB() : super(connectOnWeb());

  @override
  int get schemaVersion => 2;

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
            }));

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

  Future<void> deleteDatabase() async {
    await close(); // Ensure the database is closed before deleting

    // JavaScript code to delete IndexedDB
    js.context.callMethod('eval', [
      """
      var DBDeleteRequest = window.indexedDB.deleteDatabase('horizon_db');

      DBDeleteRequest.onerror = function(event) {
        console.log('Error deleting database.');
      };

      DBDeleteRequest.onsuccess = function(event) {
        console.log('Database deleted successfully');
      };
    """
    ]);

    print('Database deletion initiated');
  }
}

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'horizon_db', // prefer to only use valid identifiers here
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Depending how central local persistence is to your app, you may want
      // to show a warning to the user if only unrealiable implemetentations
      // are available.
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}
