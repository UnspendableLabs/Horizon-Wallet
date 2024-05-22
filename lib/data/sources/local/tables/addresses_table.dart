import 'package:drift/drift.dart';


@DataClassName("Address")
class Addresses extends Table {
  TextColumn get walletUuid => text()();
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get derivationPath => text()();

  @override
  Set<Column> get primaryKey => {address};
}

