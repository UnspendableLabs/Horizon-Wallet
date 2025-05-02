import 'package:drift/drift.dart';

class WalletConfigs extends Table {
  @JsonKey('network')
  TextColumn get network => text()();

  @JsonKey('basePath')
  TextColumn get basePath => text()();

  // maybe unnecessary since will basically always be zero
  @JsonKey('accountIndexStart')
  IntColumn get accountIndexStart => integer()();

  @JsonKey('accountIndexEnd')
  IntColumn get accountIndexEnd => integer()();

  @override
  Set<Column> get primaryKey => {network, basePath};
}
