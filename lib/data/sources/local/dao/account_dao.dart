import 'package:floor/floor.dart';
import 'package:uniparty/data/models/account.dart';

@dao
abstract class AccountDao {
  @Query('SELECT * FROM account')
  Future<List<AccountModel>> findAllAccounts();
  @Query('SELECT * FROM account WHERE uuid = :uuid')
  Future<AccountModel?> findAccountByUuid(String uuid);
  @insert
  Future<void> insertAccount(AccountModel account);
  @update
  Future<void> updateAccount(AccountModel account);
  @delete
  Future<void> deleteAccount(AccountModel account);
}



