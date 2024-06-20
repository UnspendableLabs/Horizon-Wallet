import 'package:drift/drift.dart';

class Accounts extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @JsonKey('purpose')
  TextColumn get purpose => text()();

  @JsonKey('coinType')
  IntColumn get coinType => integer()();

  @JsonKey('accountIndex')
  IntColumn get accountIndex => integer()();

  @JsonKey('xPub')
  TextColumn get xPub => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
