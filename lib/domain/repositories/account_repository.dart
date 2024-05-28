import "package:horizon/domain/entities/account.dart" as entity;

abstract class AccountRepository {
  Future<entity.Account?> getAccount(String uuid);
  Future<void> insert(entity.Account account);
  Future<entity.Account?> getCurrentAccount();

  // Future<void> initializeWithWalletAndAddresses(
  //     {Wallet wallet, List<Address> addresses});
}
