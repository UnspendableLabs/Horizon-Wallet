import 'package:drift/drift.dart';

@DataClassName("UtxoAttach")
class UtxoAttaches extends Table {
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get utxoID => text()();
  TextColumn get address => text()();
  TextColumn get asset => text()();
  BoolColumn get divisible => boolean()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {utxoID};
}
