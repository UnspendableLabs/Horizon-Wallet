import 'package:horizon/domain/entities/locked_utxo.dart';

abstract class LockedUtxoRepository {
  Future<void> insertLockedUtxo(LockedUtxo lockedUtxo);
  Future<void> deleteLockedUtxo(LockedUtxo lockedUtxo);
  Future<void> deleteLockedUtxoByTxHash(String txHash);
  Future<List<LockedUtxo>> getLockedUtxosForAddress(String address);
  Future<List<LockedUtxo>> getLockedUtxosForTxHash(String txHash);
}
