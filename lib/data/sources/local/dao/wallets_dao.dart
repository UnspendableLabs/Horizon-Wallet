import 'package:drift/drift.dart';
import 'package:horizon/data/models/wallet.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/wallets_table.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<DB> with _$WalletsDaoMixin {
  WalletsDao(super.db);

  Future<List<WalletModel>> getAllWallets() => select(wallets).get();
  Future<WalletModel?> getWalletByUuid(String uuid) =>
      (select(wallets)..where((tbl) => tbl.uuid.equals(uuid)))
          .getSingleOrNull();

  Future<WalletModel?> getCurrentWallet() async {
    final wallets_ = await select(wallets).get();

    if (wallets_.isEmpty) {
      return null;
    }

    if (wallets_.length != 1) {
      print("invariant: multiple wallets found");
    }

    return wallets_.first;
  }

  Stream<WalletModel?> watchWalletByUuid(String uuid) =>
      (select(wallets)..where((tbl) => tbl.uuid.equals(uuid))).watchSingle();
  Future<int> insertWallet(WalletModel wallet) {
    return into(wallets).insert(wallet);
  }

  Future<bool> updateWallet(Insertable<WalletModel> wallet) =>
      update(wallets).replace(wallet);
  Future<int> deleteWallet(Insertable<WalletModel> wallet) =>
      delete(wallets).delete(wallet);
  // Method to delete all wallets
  Future<int> deleteAllWallets() {
    return delete(wallets).go();
  }
}
