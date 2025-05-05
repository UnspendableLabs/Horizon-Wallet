import "package:horizon/domain/entities/account_v2.dart";
// import "package:fpdart/fpdart.dart";

abstract class AccountV2Repository {
  // Future<Option<AccountV2>> getByID(String id);
  Future<List<AccountV2>> getByWalletConfig({required String walletConfigID});
}
