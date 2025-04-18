import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/domain/services/database_manager_service.dart';
import 'dart:js' as js;
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// TODO: this should be explicitly injected in setup
DatabaseConnection connect() {
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

class DatabaseManagerWeb implements DatabaseManager {
  static final DatabaseManagerWeb _instance = DatabaseManagerWeb._internal();
  late final DB database;

  factory DatabaseManagerWeb() {
    return _instance;
  }

  DatabaseManagerWeb._internal() {
    database = DB(connect());
  }

  @override
  Future<void> deleteDatabase() async {
    await database.close(); // Ensure the database is closed before deleting

    // TODO: there's gotta be a better way to do this
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
  }
}

DatabaseManager createDatabaseManagerImpl() => DatabaseManagerWeb();
