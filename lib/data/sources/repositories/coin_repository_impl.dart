import 'package:horizon/data/models/coin.dart';
import 'package:horizon/data/sources/local/dao/coin_dao.dart';
import 'package:horizon/data/sources/local/db.dart' as local;
import 'package:horizon/domain/entities/coin.dart' as entity;
import 'package:horizon/domain/repositories/coin_repository.dart';

class CoinRepositoryImpl extends CoinRepository {
  final local.DB _db;
  final CoinsDao _coinsDao;

  CoinRepositoryImpl(this._db) : _coinsDao = CoinsDao(_db);
  @override
  Future<void> insert(entity.Coin coin) async {
    await _coinsDao.insertCoin(CoinModel(
      uuid: coin.uuid,
      walletUuid: coin.walletUuid,
      purposeUuid: coin.purposeUuid,
      type: coin.type,
    ));
  }

  @override
  Future<void> deleteCoin(entity.Coin coin) async {
    await _coinsDao.deleteCoin(CoinModel(
      uuid: coin.uuid,
      walletUuid: coin.walletUuid,
      purposeUuid: coin.purposeUuid,
      type: coin.type,
    ));
  }

  @override
  Future<entity.Coin> getCoin(String uuid) async {
    final coin = await _coinsDao.getCoinByUuid(uuid);
    return entity.Coin(
      uuid: coin!.uuid,
      walletUuid: coin!.walletUuid,
      purposeUuid: coin!.purposeUuid,
      type: coin!.type,
    );
  }

  @override
  Future<entity.Coin> getCoinByWalletUuidAndPurposeUuid(String walletUuid, String purposeUuid) async {
    final coin = await _coinsDao.getCoinByWalletUuidAndPurposeUuid(walletUuid, purposeUuid);
    return entity.Coin(
      uuid: coin!.uuid,
      walletUuid: coin!.walletUuid,
      purposeUuid: coin!.purposeUuid,
      type: coin!.type,
    );
  }
}
