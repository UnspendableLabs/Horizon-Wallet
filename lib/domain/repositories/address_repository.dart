import "package:uniparty/domain/entities/address.dart";

abstract class AddressRepository {
  Future<Address?> getAddress(String uuid);
  Future<List<Address>> getAllByWalletUuid(String walletUuid);
  Future<void> insert(Address address);
  Future<void> insertMany(List<Address> addresses);
}
