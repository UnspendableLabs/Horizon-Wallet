import "package:uniparty/domain/entities/account.dart" as entity;

abstract class AccountRepository {
  Future<entity.Account?> getAccount(String uuid);
  Future<void> insert(entity.Account account);

}
