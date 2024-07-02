import "package:horizon/data/models/address.dart";
import "package:horizon/data/sources/local/dao/addresses_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/address.dart" as entity;
import "package:horizon/domain/repositories/address_repository.dart";

class AddressRepositoryImpl implements AddressRepository {
  final local.DB _db;
  final AddressesDao _addressDao;

  AddressRepositoryImpl(this._db) : _addressDao = AddressesDao(_db);

  @override
  Future<void> insert(entity.Address address) async {
    await _addressDao
        .insertAddress(AddressModel(accountUuid: address.accountUuid, address: address.address, index: address.index));
  }

  @override
  Future<void> insertMany(List<entity.Address> addresses) async {
    // TODO: this is a little gross
    List<AddressModel> addresses_ = addresses
        .map((a) => AddressModel(
              accountUuid: a.accountUuid!,
              address: a.address,
              index: a.index,
            ))
        .toList();

    _addressDao.insertMultipleAddresses(addresses_);
  }

  @override
  Future<entity.Address?> getAddress(String uuid) async {
    throw UnimplementedError();
  }

  @override
  Future<List<entity.Address>> getAllByAccountUuid(String accountUuid) async {
    List<AddressModel> addresses = await _addressDao.getAllAddressesByAccountUuid(accountUuid);
    return addresses.map((a) => entity.Address(accountUuid: a.accountUuid, address: a.address, index: a.index)).toList();
  }
  

  @override
  Future<void> deleteAddresses(String accountUuid) async {
    await _addressDao.deleteAddresses(accountUuid);
  }

  @override
  Future<void> deleteAllAddresses() async {
    await _addressDao.deleteAllAddresses();
  }
}
