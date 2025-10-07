import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/utxo_attaches_table.dart';

part 'utxo_attaches_dao.g.dart';

@DriftAccessor(tables: [UtxoAttaches])
class UtxoAttachesDao extends DatabaseAccessor<DB> with _$UtxoAttachesDaoMixin {
  UtxoAttachesDao(super.db);

  Future<void> insert(UtxoAttach transaction) {
    return into(utxoAttaches).insert(transaction);
  }

  Future<UtxoAttach?> getByID(String utxoID) {
    return (select(utxoAttaches)..where((tbl) => tbl.utxoID.equals(utxoID)))
        .getSingleOrNull();
  }
}
