import 'package:drift/drift.dart';
import 'package:uniparty/data/sources/local/db.dart';
import 'package:uniparty/data/sources/local/tables/wallet_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<DB> with _$WalletDaoMixin {
  WalletDao(super.db);

  Future<List<Wallet>> getAllWallets() => select(wallets).get();
  Future<Wallet?> getWalletByUuid(String uuid) =>
      (select(wallets)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  Future<void> insertWallet(Insertable<Wallet> wallet) => into(wallets).insert(wallet);
  Future<void> updateWallet(Insertable<Wallet> wallet) => update(wallets).replace(wallet);
  Future<void> deleteWallet(Insertable<Wallet> wallet) => delete(wallets).delete(wallet);

  Future<List<Wallet>> findWalletsByAccountUuid(String accountUuid) =>
      (select(wallets)..where((tbl) => tbl.accountUuid.equals(accountUuid))).get();
}
