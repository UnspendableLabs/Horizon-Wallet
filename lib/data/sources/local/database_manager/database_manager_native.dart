import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/domain/services/database_manager_service.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

QueryExecutor connect() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'horizon.sqlite'));
    return NativeDatabase(file);
  });
}

class DatabaseManagerNative implements DatabaseManager {
  static final DatabaseManagerNative _instance =
      DatabaseManagerNative._internal();

  @override
  late final DB database;

  factory DatabaseManagerNative() {
    return _instance;
  }

  DatabaseManagerNative._internal() {
    database = DB(connect());
  }

  @override
  Future<void> deleteDatabase() async {
    throw UnimplementedError('deleteDatabase not implemented for web');
  }
}

DatabaseManager createDatabaseManagerImpl() => DatabaseManagerNative();
