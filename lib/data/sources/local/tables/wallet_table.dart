import 'package:drift/drift.dart';

@DataClassName('Wallet')
class Wallets extends Table {
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get accountUuid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get wif => text().withLength(min: 1, max: 100)(); // TODO: do not store wif here

  @override
  Set<Column> get primaryKey => {uuid};
}
