import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/utxo_attaches_table.dart';

part 'utxo_attaches_dao.g.dart';

@DriftAccessor(tables: [UtxoAttaches])
class UtxoAttachesDao extends DatabaseAccessor<DB> with _$UtxoAttachesDaoMixin {
  UtxoAttachesDao(super.db);

  Future<void> deleteAll() async {
    await delete(utxoAttaches).go();
  }

  Future<void> insert(UtxoAttach transaction) {
    return into(utxoAttaches).insert(transaction);
  }

  Future<List<UtxoAttach>> getAll() => select(utxoAttaches).get();

  Future<List<UtxoAttach>> getAllAfterDate(
    DateTime date,
  ) {
    return (select(utxoAttaches)
          ..where((row) {
            return row.createdAt.isBiggerOrEqualValue(date);
          }))
        .get();
  }
}
