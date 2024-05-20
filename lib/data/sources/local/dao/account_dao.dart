import 'package:floor/floor.dart';
import 'package:uniparty/data/models/account.dart';

@dao
abstract class AccountDao {

  @Query('SELECT * FROM account')
  Future<List<Account>> findAllAccounts();
  @Query('SELECT * FROM account WHERE uuid = :uuid')
  Future<Account?> findAccountByUuid(String uuid);
  @insert
  Future<void> insertAccount(Account account);
  @update
  Future<void> updateAccount(Account account);
  @delete
  Future<void> deleteAccount(Account account);
}



