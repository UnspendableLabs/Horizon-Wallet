
import "package:uniparty/domain/entities/account.dart";

abstract class AccountRepository {
  // Future<AccountEntity> getAccount();
  Future<void> insert(Account account);
  // Future<void> deleteAccount();
}

