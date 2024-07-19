import 'package:drift/drift.dart';
import "addresses_table.dart";

@DataClassName("Transaction")
class Transactions extends Table {
  TextColumn get hash => text().customConstraint('UNIQUE NOT NULL')();
  DateTimeColumn get submittedAt => dateTime()();
  TextColumn get hex => text()();
  TextColumn get source => text().references(Addresses, #address)();
  TextColumn get unpacked => text()();
  @override
  Set<Column> get primaryKey => {hash};
}
