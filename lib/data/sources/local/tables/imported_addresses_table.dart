import 'package:drift/drift.dart';

@DataClassName("ImportedAddress")
class ImportedAddresses extends Table {
  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('encryptedPrivateKey')
  TextColumn get encryptedPrivateKey =>
      text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @override
  Set<Column> get primaryKey => {address};
}
