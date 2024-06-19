import 'package:drift/drift.dart';

class Purposes extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('bip')
  TextColumn get bip => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
