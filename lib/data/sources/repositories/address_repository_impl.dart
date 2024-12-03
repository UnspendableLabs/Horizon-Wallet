import "package:horizon/data/models/address.dart";
import "package:horizon/data/sources/local/dao/addresses_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/address.dart" as entity;
import "package:horizon/domain/repositories/address_repository.dart";

class AddressRepositoryImpl implements AddressRepository {
  // ignore: unused_field
  final local.DB _db;
  final AddressesDao _addressDao;

  AddressRepositoryImpl(this._db) : _addressDao = AddressesDao(_db);

  @override
  Future<void> insert(entity.Address address) async {
    await _addressDao.insertAddress(AddressModel(
        accountUuid: address.accountUuid,
        address: address.address,
        index: address.index,
        encryptedPrivateKey: address.encryptedPrivateKey));
  }

  @override
  Future<void> insertMany(List<entity.Address> addresses) async {
    List<AddressModel> addresses_ = addresses
        .map((a) => AddressModel(
            accountUuid: a.accountUuid,
            address: a.address,
            index: a.index,
            encryptedPrivateKey: a.encryptedPrivateKey))
        .toList();

    _addressDao.insertMultipleAddresses(addresses_);
  }

  @override
  Future<entity.Address?> getAddress(String address) async {
    AddressModel? addressModel = await _addressDao.getAddress(address);
    return addressModel != null
        ? entity.Address(
            accountUuid: addressModel.accountUuid,
            address: addressModel.address,
            index: addressModel.index,
            encryptedPrivateKey: addressModel.encryptedPrivateKey)
        : null;
  }

  @override
  Future<List<entity.Address>> getAllByAccountUuid(String accountUuid) async {
    List<AddressModel> addresses =
        await _addressDao.getAllAddressesByAccountUuid(accountUuid);

    List<entity.Address> entityAddresses = addresses
        .map((a) => entity.Address(
            accountUuid: a.accountUuid,
            address: a.address,
            index: a.index,
            encryptedPrivateKey: a.encryptedPrivateKey))
        .toList();

    entityAddresses.sort(addressSortComparator);

    return entityAddresses;
  }

  @override
  Future<void> deleteAddresses(String accountUuid) async {
    await _addressDao.deleteAddresses(accountUuid);
  }

  @override
  Future<void> deleteAllAddresses() async {
    await _addressDao.deleteAllAddresses();
  }

  @override
  Future<List<entity.Address>> getAll() async {
    List<AddressModel> addresses = await _addressDao.getAllAddresses();
    return addresses
        .map((a) => entity.Address(
            accountUuid: a.accountUuid,
            address: a.address,
            index: a.index,
            encryptedPrivateKey: a.encryptedPrivateKey))
        .toList();
  }
}

// Sort addresses by index, then by address type (legacy before bech32)
int addressSortComparator(entity.Address a, entity.Address b) {
  bool aIsBech32 = a.address.startsWith('bc1q') || a.address.startsWith('tb1q');
  bool bIsBech32 = b.address.startsWith('bc1q') || b.address.startsWith('tb1q');

  if (a.index != b.index) {
    return a.index.compareTo(b.index);
  } else if (aIsBech32 && !bIsBech32) {
    return 1;
  } else if (!aIsBech32 && bIsBech32) {
    return -1;
  } else {
    return 0;
  }
}
