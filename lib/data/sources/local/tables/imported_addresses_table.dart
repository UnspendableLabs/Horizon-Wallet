import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text().customConstraint("NOT NULL DEFAULT ''")();

  @JsonKey('encryptedWif')
  TextColumn get encryptedWif => text().customConstraint('UNIQUE NOT NULL')();

  @override
  Set<Column> get primaryKey => {address};
}
