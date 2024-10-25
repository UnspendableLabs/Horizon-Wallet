import 'package:drift/drift.dart';
import 'package:horizon/data/models/imported_address.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/imported_addresses_table.dart';

part 'imported_addresses_dao.g.dart';

@DriftAccessor(tables: [ImportedAddresses])
class ImportedAddressesDao extends DatabaseAccessor<DB> with _$ImportedAddressesDaoMixin {
  ImportedAddressesDao(super.db);

  Future<List<ImportedAddress>> getAllAddresses() => select(importedAddresses).get();
  Future<ImportedAddress?> getAddress(String address) =>
      (select(importedAddresses)..where((tbl) => tbl.address.equals(address))).getSingle();

  Future<int> insertAddress(ImportedAddressModel address) {
    return into(importedAddresses).insert(address);
  }

  Future<void> insertMultipleAddresses(List<ImportedAddressModel> addresses_) async {
    await batch((batch) {
      batch.insertAll(importedAddresses, addresses_);
    });
  }

  Future<bool> updateAddress(Insertable<ImportedAddressModel> address) => update(importedAddresses).replace(address);
  Future<int> deleteAddress(Insertable<ImportedAddressModel> address) => delete(importedAddresses).delete(address);
  // Future<void> deleteAddresses(String accountUuid) async {
  //   await (delete(importedAddresses)
  //         ..where((tbl) => tbl.accountUuid.equals(accountUuid)))
  //       .go();
  // }

  Future<int> deleteAllAddresses() {
    return delete(importedAddresses).go();
  }
}
