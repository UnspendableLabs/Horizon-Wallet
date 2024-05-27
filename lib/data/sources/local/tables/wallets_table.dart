import 'package:drift/drift.dart';

class Wallets extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('name')
  TextColumn get name => text()();

  @JsonKey('accountUuid')
  TextColumn get accountUuid => text()();

  @JsonKey('publicKey')
  TextColumn get publicKey => text()();

  @JsonKey('wif')
  TextColumn get wif => text()(); // TODO: do not store wif here

  @override
  Set<Column> get primaryKey => {uuid};
}
