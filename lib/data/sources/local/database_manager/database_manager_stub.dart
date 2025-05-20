import 'package:horizon/domain/services/database_manager_service.dart';

class DatabaseManagerStub implements DatabaseManager {
  @override
  Future<void> deleteDatabase() async {
    throw UnimplementedError(
        '[DatabaseManagerStub] deleteDatabase() is not supported on this platform.');
  }

  @override
  dynamic get database {
    throw UnimplementedError(
        '[DatabaseManagerStub] database getter is not supported on this platform.');
  }
}

DatabaseManager createDatabaseManagerImpl() => DatabaseManagerStub();
