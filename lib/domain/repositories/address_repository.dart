import "package:horizon/domain/entities/address.dart";

abstract class AddressRepository {
  Future<Address?> getAddress(String uuid);
  Future<List<Address>> getAllByAccountUuid(String accountUuid);
  Future<void> insert(Address address);
  Future<void> insertMany(List<Address> addresses);
  Future<void> deleteAddresses(String walletUuid);
  Future<void> deleteAllAddresses();
  Future<List<Address>> getAll();
  Future<void> updateAddressEncryptedPrivateKey(
      String address, String encryptedPrivateKey);
  Future<List<Address>> getAddressesWithNullPrivateKey();
  Future<void> updateAddressesEncryptedPrivateKeys(
      Map<String, String> addressToEncryptedPrivateKey);
}
