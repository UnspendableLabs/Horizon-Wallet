import 'package:drift/drift.dart';

class Coins extends Table {
  @JsonKey('uuid')
  TextColumn get uuid => text()();

  @JsonKey('type')
  IntColumn get type => integer()();

  @JsonKey('purposeUuid')
  TextColumn get purposeUuid => text()();

  @JsonKey('walletUuid')
  TextColumn get walletUuid => text()();
}
