import "package:uniparty/domain/entities/account.dart" as entity;
import "package:uniparty/domain/entities/wallet.dart";
import "package:uniparty/domain/entities/address.dart";

abstract class AccountRepository {
  Future<entity.Account?> getAccount(String uuid);
  Future<void> insert(entity.Account account);

  // Future<void> initializeWithWalletAndAddresses(
  //     {Wallet wallet, List<Address> addresses});
}
