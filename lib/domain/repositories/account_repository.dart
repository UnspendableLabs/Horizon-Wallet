import "package:horizon/domain/entities/account.dart" as entity;

abstract class AccountRepository {
  Future<entity.Account?> getAccountByUuid(String uuid);
  Future<List<entity.Account>> getAccountsForWalletPurposeAndCoin(String walletUuid, String purposeUuid, String coinUuid);
  Future<void> insert(entity.Account account);
  Future<void> deleteAccount(entity.Account account);
  Future<void> deleteAllAccounts();
}
