import 'package:drift/drift.dart';

@DataClassName("Transaction")
class Transactions extends Table {
  TextColumn get hash => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get raw => text()();
  TextColumn get source => text()();
  TextColumn get destination => text().nullable()();
  IntColumn get btcAmount => integer().nullable()();
  IntColumn get fee => integer().nullable()();
  TextColumn get data => text()();
  TextColumn get unpackedData => text().nullable()();
  DateTimeColumn get submittedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {hash};
}
