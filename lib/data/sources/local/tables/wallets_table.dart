import 'package:drift/drift.dart';

class Wallets extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
