import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();
  @override
  Set<Column> get primaryKey => {uuid};
}


