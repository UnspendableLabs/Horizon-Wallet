import "package:horizon/domain/entities/account_v2.dart";

abstract class AccountV2Repository {
  Future<List<AccountV2>> getAll();
  Future<void> insert(AccountV2 account);
  Future<void> deleteAll();
}
