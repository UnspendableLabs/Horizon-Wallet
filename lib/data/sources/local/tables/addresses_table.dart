import 'package:drift/drift.dart';

@DataClassName("Address")
class Addresses extends Table {
  @JsonKey('accountUuid')
  TextColumn get accountUuid => text()();

  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('index')
  IntColumn get index => integer()();

  @override
  Set<Column> get primaryKey => {accountUuid, index};
}
