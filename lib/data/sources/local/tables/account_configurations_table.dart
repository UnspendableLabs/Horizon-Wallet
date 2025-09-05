import 'package:drift/drift.dart';

class AccountConfigurations extends Table {
  @JsonKey("walletUUID")
  TextColumn get walletUUID => text()();

  @JsonKey('index')
  IntColumn get index => integer()();

  @JsonKey('addressIndex')
  IntColumn get addressIndex => integer()();

  @override
  Set<Column> get primaryKey => {walletUUID, index};
}
