

import 'package:floor/floor.dart';
import 'package:uniparty/data/models/address.dart';

@dao
abstract class AddressDao {
  @Query('SELECT * FROM address')
  Future<List<Address>> findAllAddresss();
  @Query('SELECT * FROM address WHERE uuid = :uuid')
  Future<Address?> findAddressByUuid(String uuid);
  @insert
  Future<void> insertAddress(Address address);
  @update
  Future<void> updateAddress(Address address);
  @delete
  Future<void> deleteAddress(Address address);

  @Query('SELECT * FROM address WHERE accountUuid = :accountUuid')
  Future<List<Address>> findAddresssByAccountUuid(String accountUuid);

}
