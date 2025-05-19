import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('encryptedWif')
  TextColumn get encryptedWif => text().customConstraint('NOT NULL UNIQUE')();
  
  @JsonKey('network')
  TextColumn get network => text()();

  @override
  Set<Column> get primaryKey => {encryptedWif};
}
