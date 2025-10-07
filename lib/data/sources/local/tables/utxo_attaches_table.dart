import 'package:drift/drift.dart';

@DataClassName("UtxoAttach")
class UtxoAttaches extends Table {
  TextColumn get txid => text().customConstraint('UNIQUE NOT NULL')();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get utxoTxid => text()();

  @override
  Set<Column> get primaryKey => {txid};
}
