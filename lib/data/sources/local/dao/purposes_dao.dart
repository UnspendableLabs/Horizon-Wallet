import 'package:drift/drift.dart';
import 'package:horizon/data/models/purpose.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/purposes_table.dart';

part 'purposes_dao.g.dart';

@DriftAccessor(tables: [Purposes])
class PurposesDao extends DatabaseAccessor<DB> with _$PurposesDaoMixin {
  PurposesDao(super.db);

  Future<PurposeModel?> getPurposeByUuid(String uuid) =>
      (select(purposes)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  Future<List<PurposeModel>> getPurposesByWalletUuid(String walletUuid) =>
      (select(purposes)..where((tbl) => tbl.walletUuid.equals(walletUuid))).get();
  Future<void> insertPurpose(Insertable<PurposeModel> purpose) => into(purposes).insert(purpose);
  Future<void> deletePurpose(Insertable<PurposeModel> purpose) => delete(purposes).delete(purpose);
}
