import "package:horizon/domain/entities/account.dart" as entity;

abstract class AccountRepositoryDeprecated {
  Future<entity.Account?> getAccountByUuid(String uuid);
  Future<List<entity.Account>> getAccountsByWalletUuid(String walletUuid);
  Future<List<entity.Account>> getAll();
  Future<void> insert(entity.Account account);
  Future<void> deleteAccount(entity.Account account);
  Future<void> deleteAllAccounts();
}
