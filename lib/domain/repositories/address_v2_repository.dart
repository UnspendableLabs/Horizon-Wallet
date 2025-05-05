import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";

abstract class AddressV2Repository {
  Future<List<AddressV2>> getByAccount(AccountV2 account);
}
