
import "package:uniparty/data/sources/local/db.dart";
import "package:uniparty/data/models/address.dart";
import "package:uniparty/domain/repositories/address_repository.dart";
import "package:uniparty/domain/entities/address_entity.dart";

class AddressRepositoryImpl implements AddressRepository {
  final DB _db;

  AddressRepositoryImpl(this._db);

  @override
  Future<void> insert(AddressEntity address) {
    return _db.addressDao.insertAddress(Address.fromEntity(address));
  }
}

