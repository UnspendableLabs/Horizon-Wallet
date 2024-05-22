import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get defaultWalletUuid => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}


