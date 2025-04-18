// data/services/database_manager_factory.dart

import 'package:horizon/domain/services/database_manager_service.dart';

import './database_manager_stub.dart'
    if (dart.library.io) './database_manager_native.dart'
    if (dart.library.html) './database_manager_web.dart';

DatabaseManager createDatabaseManager() => createDatabaseManagerImpl();
