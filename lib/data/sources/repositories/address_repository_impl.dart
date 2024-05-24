import "package:uniparty/data/models/address.dart";
import "package:uniparty/data/sources/local/dao/addresses_dao.dart";
import "package:uniparty/data/sources/local/db.dart" as local;
import "package:uniparty/domain/entities/address.dart" as entity;
import "package:uniparty/domain/repositories/address_repository.dart";

class AddressRepositoryImpl implements AddressRepository {
  final local.DB _db;
  final AddressesDao _addressDao;

  AddressRepositoryImpl(this._db) : _addressDao = AddressesDao(_db);

  @override
  Future<void> insert(entity.Address address) async {
    throw UnimplementedError();
  }

  @override
  Future<void> insertMany(List<entity.Address> addresses) async {
    // TODO: this is a little gross
    List<AddressModel> addresses_ = addresses
        .map((a) => AddressModel(walletUuid: a.walletUuid!, address: a.address, derivationPath: a.derivationPath))
        .toList();

    _addressDao.insertMultipleAddresses(addresses_);
  }

  @override
  Future<entity.Address?> getAddress(String uuid) async {
    throw UnimplementedError();
  }

  @override
  Future<List<entity.Address>> getAllByWalletUuid(String walletUuid) async {
    List<AddressModel> addresses = await _addressDao.getAllAddressesByWalletUuid(walletUuid);
    return addresses
        .map((a) => entity.Address(walletUuid: a.walletUuid, address: a.address, derivationPath: a.derivationPath))
        .toList();
  }
}
