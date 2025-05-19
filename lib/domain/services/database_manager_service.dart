import 'package:drift/drift.dart';

abstract class DatabaseManager {
  Future<void> deleteDatabase();
  dynamic get database;
}
