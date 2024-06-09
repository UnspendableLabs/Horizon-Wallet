import 'package:drift/drift.dart';

@DataClassName("Address")
class Addresses extends Table {
  @JsonKey('accountUuid')
  TextColumn get accountUuid => text()();

  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('derivationPath')
  TextColumn get derivationPath => text()();

  @JsonKey('publicKey')
  TextColumn get publicKey => text()();

  @JsonKey('privateKeyWif')
  TextColumn get privateKeyWif => text()(); // TODO: do not store privKey here

  @override
  Set<Column> get primaryKey => {address};
}
