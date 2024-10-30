import "package:horizon/data/models/imported_address.dart";
import "package:horizon/data/sources/local/dao/imported_addresses_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/imported_address.dart" as entity;
import "package:horizon/domain/repositories/imported_address_repository.dart";

class ImportedAddressRepositoryImpl implements ImportedAddressRepository {
  // ignore: unused_field
  final local.DB _db;
  final ImportedAddressesDao _importedAddressDao;

  ImportedAddressRepositoryImpl(this._db)
      : _importedAddressDao = ImportedAddressesDao(_db);

  @override
  Future<void> insert(entity.ImportedAddress address) async {
    await _importedAddressDao.insertImportedAddress(ImportedAddressModel(
        walletUuid: address.walletUuid,
        address: address.address,
        name: address.name,
        encryptedWif: address.encryptedWif));
  }

  @override
  Future<void> insertMany(List<entity.ImportedAddress> addresses) async {
    List<ImportedAddressModel> addresses_ = addresses
        .map((a) => ImportedAddressModel(
            walletUuid: a.walletUuid,
            address: a.address,
            name: a.name,
            encryptedWif: a.encryptedWif))
        .toList();

    _importedAddressDao.insertMultipleImportedAddresses(addresses_);
  }

  @override
  Future<entity.ImportedAddress?> getImportedAddress(String address) async {
    ImportedAddressModel? addressModel =
        await _importedAddressDao.getImportedAddress(address);
    return addressModel != null
        ? entity.ImportedAddress(
            walletUuid: addressModel.walletUuid,
            address: addressModel.address,
            name: addressModel.name,
            encryptedWif: addressModel.encryptedWif)
        : null;
  }

  @override
  Future<List<entity.ImportedAddress>> getAllByWalletUuid(
      String walletUuid) async {
    List<ImportedAddressModel> addresses = await _importedAddressDao
        .getAllImportedAddressesByWalletUuid(walletUuid);

    List<entity.ImportedAddress> entityAddresses = addresses
        .map((a) => entity.ImportedAddress(
            walletUuid: a.walletUuid,
            address: a.address,
            name: a.name,
            encryptedWif: a.encryptedWif))
        .toList();

    return entityAddresses;
  }

  @override
  Future<void> deleteImportedAddressesByWalletUuid(String walletUuid) async {
    await _importedAddressDao.deleteImportedAddressesByWalletUuid(walletUuid);
  }

  @override
  Future<void> deleteAllImportedAddresses() async {
    await _importedAddressDao.deleteAllImportedAddresses();
  }

  @override
  Future<List<entity.ImportedAddress>> getAll() async {
    List<ImportedAddressModel> importedAddresses =
        await _importedAddressDao.getAllImportedAddresses();
    return importedAddresses
        .map((a) => entity.ImportedAddress(
            walletUuid: a.walletUuid,
            address: a.address,
            name: a.name,
            encryptedWif: a.encryptedWif))
        .toList();
  }
}
