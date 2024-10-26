import 'package:drift/drift.dart';
import 'package:horizon/data/models/address.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/addresses_table.dart';

part 'addresses_dao.g.dart';

@DriftAccessor(tables: [Addresses])
class AddressesDao extends DatabaseAccessor<DB> with _$AddressesDaoMixin {
  AddressesDao(super.db);

  Future<List<Address>> getAllAddresses() => select(addresses).get();
  Future<Address?> getAddress(String address) =>
      (select(addresses)..where((tbl) => tbl.address.equals(address)))
          .getSingle();
  Future<List<Address>> getAllAddressesByAccountUuid(String accountUuid) =>
      (select(addresses)..where((tbl) => tbl.accountUuid.equals(accountUuid)))
          .get();

  Future<int> insertAddress(AddressModel address) {
    return into(addresses).insert(address);
  }

  Future<void> insertMultipleAddresses(List<AddressModel> addresses_) async {
    await batch((batch) {
      batch.insertAll(addresses, addresses_);
    });
  }

  Future<bool> updateAddress(Insertable<AddressModel> address) =>
      update(addresses).replace(address);
  Future<int> deleteAddress(Insertable<AddressModel> address) =>
      delete(addresses).delete(address);
  Future<void> deleteAddresses(String accountUuid) async {
    await (delete(addresses)
          ..where((tbl) => tbl.accountUuid.equals(accountUuid)))
        .go();
  }

  Future<int> deleteAllAddresses() {
    return delete(addresses).go();
  }

  Future<void> updateAddressEncryptedPrivateKey(
      String address, String encryptedPrivateKey) async {
    await (update(addresses)..where((tbl) => tbl.address.equals(address)))
        .write(AddressesCompanion(
      encryptedPrivateKey: Value(encryptedPrivateKey),
    ));
  }
}
