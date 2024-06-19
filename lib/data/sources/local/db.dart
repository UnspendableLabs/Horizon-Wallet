import 'dart:js' as js;

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';
import 'package:horizon/data/sources/local/tables/coins_table.dart';
import 'package:horizon/data/sources/local/tables/purposes_table.dart';
import "package:horizon/data/sources/local/tables/wallets_table.dart";

part "db.g.dart";

@DriftDatabase(tables: [Wallets, Purposes, Coins, Accounts, Addresses])
class DB extends _$DB {
  DB() : super(connectOnWeb());

  @override
  int get schemaVersion => 1;

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
