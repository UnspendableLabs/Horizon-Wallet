
import "package:uniparty/domain/entities/address.dart";
import "package:uniparty/domain/entities/wallet.dart";
import "package:uniparty/domain/entities/address.dart";

abstract class AddressRepository {
  Future<Address?> getAddress(String uuid);
  Future<void> insert(Address address);
  Future<void> insertMany(List<Address> addresses);
}
