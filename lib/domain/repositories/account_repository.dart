
import "package:uniparty/domain/entities/account_entity.dart";

abstract class AccountRepository {
  // Future<AccountEntity> getAccount();
  Future<void> insert(AccountEntity account);
  // Future<void> deleteAccount();
}

