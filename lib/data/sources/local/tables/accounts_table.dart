import 'package:drift/drift.dart';

class Accounts extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @JsonKey('purpose')
  TextColumn get purpose => text()(); // add constraints

  @JsonKey('coinType')
  TextColumn get coinType => text()(); // add constraints

  @JsonKey('accountIndex')
  TextColumn get accountIndex => text()(); // add constraints

  @override
  Set<Column> get primaryKey => {uuid};
}
