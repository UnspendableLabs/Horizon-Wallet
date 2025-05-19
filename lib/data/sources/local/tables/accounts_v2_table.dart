import 'package:drift/drift.dart';

class AccountsV2 extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('index')
  IntColumn get index => integer()();

  @override
  Set<Column> get primaryKey => {uuid};
}
