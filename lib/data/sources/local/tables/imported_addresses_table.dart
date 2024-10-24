import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('index')
  IntColumn get index => integer()();

  @JsonKey('encryptedPrivateKey')
  TextColumn get encryptedPrivateKey =>
      text().customConstraint('UNIQUE NOT NULL')();

  @override
  Set<Column> get primaryKey => {address};
}
