import "dart:async";

import 'package:sqflite/sqflite.dart' as sqflite;
import "package:floor/floor.dart";

import "package:uniparty/data/sources/local/dao/account_dao.dart";
import "package:uniparty/data/models/account.dart";

part "db.g.dart";

@Database(version: 1, entities: [Account])
abstract class DB extends FloorDatabase {
  AccountDao get accountDao;
}
