
import 'package:floor/floor.dart';
import 'package:uniparty/data/models/wallet.dart';

@dao
abstract class WalletDao {
  @Query('SELECT * FROM wallet')
  Future<List<Wallet>> findAllWallets();
  @Query('SELECT * FROM wallet WHERE uuid = :uuid')
  Future<Wallet?> findWalletByUuid(String uuid);
  @insert
  Future<void> insertWallet(Wallet wallet);
  @update
  Future<void> updateWallet(Wallet wallet);
  @delete
  Future<void> deleteWallet(Wallet wallet);

  @Query('SELECT * FROM wallet WHERE accountUuid = :accountUuid')
  Future<List<Wallet>> findWalletsByAccountUuid(String accountUuid);

}



