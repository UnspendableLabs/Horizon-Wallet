import 'package:drift/drift.dart';

class Purposes extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
