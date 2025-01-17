import "package:horizon/domain/entities/imported_address.dart";

abstract class ImportedAddressRepository {
  Future<ImportedAddress?> getImportedAddress(String address);
  Future<void> insert(ImportedAddress address);
  Future<void> insertMany(List<ImportedAddress> addresses);
  Future<void> deleteAllImportedAddresses();
  Future<List<ImportedAddress>> getAll();
}
