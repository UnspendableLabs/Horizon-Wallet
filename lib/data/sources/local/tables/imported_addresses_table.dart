import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('address')
  TextColumn get address => text().customConstraint('NOT NULL UNIQUE')();

  @JsonKey('name')
  TextColumn get name => text().customConstraint("NOT NULL DEFAULT ''")();

  @JsonKey('encryptedWif')
  TextColumn get encryptedWif => text().customConstraint('NOT NULL UNIQUE')();

  @override
  Set<Column> get primaryKey => {address};
}
