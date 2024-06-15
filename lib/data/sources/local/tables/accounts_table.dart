import 'package:drift/drift.dart';

class Accounts extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @JsonKey('rootPublicKey')
  TextColumn get rootPublicKey => text()();

  @JsonKey('rootPrivateKey')
  TextColumn get rootPrivateKey => text()(); // TODO: do not store privKey here

  @override
  Set<Column> get primaryKey => {uuid};
}
