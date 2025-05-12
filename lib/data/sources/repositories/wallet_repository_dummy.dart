import "package:horizon/data/sources/local/dao/wallets_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet.dart" as entity;
import "package:horizon/domain/repositories/wallet_repository.dart";

class WalletRepositoryDummy implements WalletRepository {
  // ignore: unused_field
  final local.DB _db;
  final WalletsDao _walletDao;

  WalletRepositoryDummy(this._db) : _walletDao = WalletsDao(_db);

  @override
  Future<void> insert(entity.Wallet wallet) async {
    try {
      throw UnimplementedError();
    } catch (error, callstack) {
      print(callstack);
      rethrow;
    }
  }

  @override
  Future<entity.Wallet?> getWallet(String uuid) async {
    try {
      throw UnimplementedError();
    } catch (error, callstack) {
      print(callstack);
      rethrow;
    }
  }

  @override
  Future<entity.Wallet?> getCurrentWallet() async {
    try {
      throw UnimplementedError();
    } catch (error, callstack) {
      print(callstack);
      rethrow;
    }
  }

  @override
  Future<void> deleteWallet(entity.Wallet wallet) async {
    try {
      throw UnimplementedError();
    } catch (error, callstack) {
      print(callstack);
      rethrow;
    }
  }

  @override
  Future<void> deleteAllWallets() async {
    try {
      throw UnimplementedError();
    } catch (error, callstack) {
      print(callstack);
      rethrow;
    }
  }
}
