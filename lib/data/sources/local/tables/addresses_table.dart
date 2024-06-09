import 'package:drift/drift.dart';

@DataClassName("Address")
class Addresses extends Table {
  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();

  @JsonKey('address')
  TextColumn get address => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('derivationPath')
  TextColumn get derivationPath => text()();

  @override
  Set<Column> get primaryKey => {address};
}
