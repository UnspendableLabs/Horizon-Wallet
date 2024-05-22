import 'package:drift/drift.dart';
import 'package:uniparty/data/sources/local/db.dart';
import 'package:uniparty/data/sources/local/tables/wallets_table.dart';
import 'package:uniparty/data/models/wallet.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<DB> with _$WalletsDaoMixin {
  WalletsDao(super.db);

  Future<List<WalletModel>> getAllWallets() => select(wallets).get();
  Future<WalletModel?> getWalletByUuid(String uuid) =>
      (select(wallets)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  Future<void> insertWallet(Insertable<WalletModel> wallet) => into(wallets).insert(wallet);
  Future<void> updateWallet(Insertable<WalletModel> wallet) => update(wallets).replace(wallet);
  Future<void> deleteWallet(Insertable<WalletModel> wallet) => delete(wallets).delete(wallet);

  Future<List<WalletModel>> findWalletsByAccountUuid(String accountUuid) =>
      (select(wallets)..where((tbl) => tbl.accountUuid.equals(accountUuid))).get();
}
