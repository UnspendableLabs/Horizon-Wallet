
import "package:uniparty/data/sources/local/db.dart";
import "package:uniparty/data/models/address.dart";
import "package:uniparty/domain/repositories/address_repository.dart";
import "package:uniparty/domain/entities/address.dart";

class AddressRepositoryImpl implements AddressRepository {
  final DB _db;

  AddressRepositoryImpl(this._db);

  @override
  Future<void> insert(Address address) {
    return _db.addressDao.insertAddress(AddressModel.fromEntity(address));
  }
}

