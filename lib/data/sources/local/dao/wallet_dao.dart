
import 'package:floor/floor.dart';
import 'package:uniparty/data/models/wallet.dart';

@dao
abstract class WalletDao {
  @Query('SELECT * FROM wallet')
  Future<List<WalletModel>> findAllWallets();
  @Query('SELECT * FROM wallet WHERE uuid = :uuid')
  Future<WalletModel?> findWalletByUuid(String uuid);
  @insert
  Future<void> insertWallet(WalletModel wallet);
  @update
  Future<void> updateWallet(WalletModel wallet);
  @delete
  Future<void> deleteWallet(WalletModel wallet);

  @Query('SELECT * FROM wallet WHERE accountUuid = :accountUuid')
  Future<List<WalletModel>> findWalletsByAccountUuid(String accountUuid);

}



