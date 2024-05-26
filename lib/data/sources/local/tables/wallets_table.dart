import 'package:drift/drift.dart';

class Wallets extends Table {
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get name => text()();
  TextColumn get accountUuid => text()();
  TextColumn get publicKey => text()();
  TextColumn get wif => text()(); // TODO: do not store wif here

  @override
  Set<Column> get primaryKey => {uuid};
}
