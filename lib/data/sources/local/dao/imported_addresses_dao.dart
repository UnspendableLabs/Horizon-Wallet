import 'package:drift/drift.dart';
import 'package:horizon/data/models/imported_address.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/imported_addresses_table.dart';

part 'imported_addresses_dao.g.dart';

@DriftAccessor(tables: [ImportedAddresses])
class ImportedAddressesDao extends DatabaseAccessor<DB>
    with _$ImportedAddressesDaoMixin {
  ImportedAddressesDao(super.db);

  Future<List<ImportedAddress>> getAllImportedAddresses() =>
      select(importedAddresses).get();

  Future<List<ImportedAddress>> getAllImportedAddressesByWalletUuid(
          String walletUuid) =>
      (select(importedAddresses)
            ..where((tbl) => tbl.walletUuid.equals(walletUuid)))
          .get();

  Future<ImportedAddress?> getImportedAddress(String address) =>
      (select(importedAddresses)..where((tbl) => tbl.address.equals(address)))
          .getSingleOrNull();

  Future<int> insertImportedAddress(ImportedAddressModel address) {
    return into(importedAddresses).insert(address);
  }

  Future<void> insertMultipleImportedAddresses(
      List<ImportedAddressModel> addresses_) async {
    await batch((batch) {
      batch.insertAll(importedAddresses, addresses_);
    });
  }

  Future<bool> updateImportedAddress(
          Insertable<ImportedAddressModel> address) =>
      update(importedAddresses).replace(address);
  Future<int> deleteImportedAddress(Insertable<ImportedAddressModel> address) =>
      delete(importedAddresses).delete(address);
  Future<void> deleteImportedAddressesByWalletUuid(String walletUuid) async {
    await (delete(importedAddresses)
          ..where((tbl) => tbl.walletUuid.equals(walletUuid)))
        .go();
  }

  Future<int> deleteAllImportedAddresses() {
    return delete(importedAddresses).go();
  }
}
