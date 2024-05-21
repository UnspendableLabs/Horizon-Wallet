import "dart:async";

import 'package:sqflite/sqflite.dart' as sqflite;
import "package:floor/floor.dart";

import "package:uniparty/data/sources/local/dao/account_dao.dart";
import "package:uniparty/data/models/account.dart";

import "package:uniparty/data/sources/local/dao/wallet_dao.dart";
import "package:uniparty/data/models/wallet.dart";

import "package:uniparty/data/sources/local/dao/address_dao.dart";
import "package:uniparty/data/models/address.dart";

part "db.g.dart";

@Database(version: 1, entities: [AccountModel, WalletModel, AddressModel])
abstract class DB extends FloorDatabase {
  AccountDao get accountDao;
  WalletDao get walletDao;
  AddressDao get addressDao;
}
