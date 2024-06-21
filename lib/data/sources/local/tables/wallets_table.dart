import 'package:drift/drift.dart';

class Wallets extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('encryptedPrivKey')
  TextColumn get encryptedPrivKey => text()();

  @JsonKey('chainCodeHex')
  TextColumn get chainCodeHex => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
