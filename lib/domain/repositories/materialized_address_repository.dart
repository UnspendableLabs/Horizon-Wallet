import "package:horizon/domain/entities/address.dart";
import "package:horizon/domain/entities/account.dart";

abstract class MaterializedAddressRepository {
  Future<List<Address>> getAddresses(Account account, int gapLimit,
      [bool change = false]);
}
