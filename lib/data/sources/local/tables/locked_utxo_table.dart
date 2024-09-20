import 'package:drift/drift.dart';

@DataClassName('LockedUtxo')
class LockedUtxos extends Table {
  TextColumn get id => text()(); // Unique identifier, txid:vout
  TextColumn get txHash => text()();
  TextColumn get txid => text()();
  IntColumn get vout => integer()();
  TextColumn get address => text()();
  IntColumn get value => integer()();
  DateTimeColumn get lockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
