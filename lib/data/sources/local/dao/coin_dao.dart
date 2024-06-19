import 'package:drift/drift.dart';
import 'package:horizon/data/models/coin.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/coins_table.dart';

part 'coin_dao.g.dart';

@DriftAccessor(tables: [Coins])
class CoinsDao extends DatabaseAccessor<DB> with _$CoinsDaoMixin {
  CoinsDao(super.db);

  Future<CoinModel?> getCoinByUuid(String uuid) => (select(coins)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  Future<List<CoinModel>> getCoinByWalletUuidAndPurposeUuid(String walletUuid, String purposeUuid) =>
      (select(coins)..where((tbl) => tbl.walletUuid.equals(walletUuid) & tbl.purposeUuid.equals(purposeUuid))).get();
  Future<void> insertCoin(Insertable<CoinModel> coin) => into(coins).insert(coin);
  Future<void> deleteCoin(Insertable<CoinModel> coin) => delete(coins).delete(coin);
}
