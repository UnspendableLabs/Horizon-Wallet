import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:horizon/data/sources/local/tables/accounts_table.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';
import "package:horizon/data/sources/local/tables/wallets_table.dart";

part "db.g.dart";

@DriftDatabase(tables: [Wallets, Accounts, Addresses])
class DB extends _$DB {
  DB() : super(connectOnWeb());

  @override
  int get schemaVersion => 1;
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
