import 'package:drift/drift.dart';

@DataClassName('Account')
class Accounts extends Table {
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get defaultWalletUuid => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}
