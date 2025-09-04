import 'package:drift/drift.dart';

class WalletConfigs extends Table {
  // this is useful for querying but primaryKey is always composite of network + basePath
  @JsonKey('uuid')
  TextColumn get uuid => text().customConstraint('UNIQUE NOT NULL')();

  @JsonKey('network')
  TextColumn get network => text()();

  @JsonKey('basePath')
  TextColumn get basePath => text()();

  // maybe unnecessary since will basically always be zero
  @JsonKey('accountIndexStart')
  IntColumn get accountIndexStart => integer()();

  @JsonKey('accountIndexEnd')
  IntColumn get accountIndexEnd => integer()();

  @JsonKey('seedDerivation')
  TextColumn get seedDerivation => text()();

  @JsonKey('addrKindsMask')
  IntColumn get addrKindsMask => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {network, basePath, seedDerivation};
}
