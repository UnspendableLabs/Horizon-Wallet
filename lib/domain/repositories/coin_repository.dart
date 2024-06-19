import 'package:horizon/domain/entities/coin.dart' as entity;

abstract class CoinRepository {
  Future<entity.Coin?> getCoin(String uuid);
  Future<void> insert(entity.Coin coin);
  Future<entity.Coin?> getCoinByWalletUuidAndPurposeUuid(String walletUuid, String purposeUuid);
  Future<void> deleteCoin(entity.Coin coin);
  // Future<void> deleteAllCoins();
}
