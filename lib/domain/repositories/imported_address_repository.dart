import "package:horizon/domain/entities/imported_address.dart";

abstract class ImportedAddressRepository {
  Future<ImportedAddress?> getImportedAddress(String uuid);
  Future<List<ImportedAddress>> getAllByWalletUuid(String walletUuid);
  Future<void> insert(ImportedAddress address);
  Future<void> insertMany(List<ImportedAddress> addresses);
  Future<void> deleteImportedAddressesByWalletUuid(String walletUuid);
  Future<void> deleteAllImportedAddresses();
  Future<List<ImportedAddress>> getAll();
}
