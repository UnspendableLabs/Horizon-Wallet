import 'package:drift/drift.dart';
import "addresses_table.dart";

@DataClassName("Transaction")
class Transactions extends Table {
  TextColumn get hash => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get raw => text()();
  TextColumn get source => text()();
  TextColumn get destination => text().nullable()();
  IntColumn get btcAmount => integer()();
  IntColumn get fee => integer()();
  TextColumn get data => text()();
  TextColumn get unpackedData => text()();
  DateTimeColumn get submittedAt => dateTime()();
  Set<Column> get primaryKey => {hash};
}
