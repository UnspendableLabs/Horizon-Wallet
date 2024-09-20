import 'package:drift/drift.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/locked_utxo_table.dart';

part 'locked_utxo_dao.g.dart';

@DriftAccessor(tables: [LockedUtxos])
class LockedUtxoDao extends DatabaseAccessor<DB> with _$LockedUtxoDaoMixin {
  LockedUtxoDao(super.db);

  Future<List<LockedUtxo>> getLockedUtxosForAddress(String address) {
    return (select(lockedUtxos)..where((tbl) => tbl.address.equals(address)))
        .get();
  }

  Future<List<LockedUtxo>> getLockedUtxosForTxHash(String txHash) {
    return (select(lockedUtxos)..where((tbl) => tbl.txHash.equals(txHash)))
        .get();
  }

  Future<void> insertLockedUtxo(LockedUtxo lockedUtxo) {
    return into(lockedUtxos)
        .insert(lockedUtxo, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteLockedUtxo(LockedUtxo lockedUtxo) {
    return delete(lockedUtxos).delete(lockedUtxo);
  }

  Future<void> deleteLockedUtxoByTxHash(String txHash) {
    return (delete(lockedUtxos)..where((tbl) => tbl.txHash.equals(txHash)))
        .go();
  }
}
