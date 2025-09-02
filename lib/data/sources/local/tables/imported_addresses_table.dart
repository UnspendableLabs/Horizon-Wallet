import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('encryptedWif')
  TextColumn get encryptedWif => text().customConstraint('NOT NULL')();

  @JsonKey('network')
  TextColumn get network => text()();

  @JsonKey('type_')
  TextColumn get type_ => text()();

  // .withDefault(const Constant('p2wpkh'))();

  @override
  Set<Column> get primaryKey => {encryptedWif, network, type_};
}
