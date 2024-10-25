import 'package:drift/drift.dart';

@DataClassName("Address")
class Addresses extends Table {
  @JsonKey('accountUuid')
  TextColumn get accountUuid => text()();

  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('index')
  IntColumn get index => integer()();

  @JsonKey('encryptedPrivateKey')
  TextColumn get encryptedPrivateKey => text().nullable()();
  @override
  Set<Column> get primaryKey => {address};
}
