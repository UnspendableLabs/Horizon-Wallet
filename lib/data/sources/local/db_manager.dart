import 'package:horizon/data/sources/local/db.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  late final DB database;

  factory DatabaseManager() {
    return _instance;
  }

  DatabaseManager._internal() {
    database = DB();
  }
}
