import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<List<Utxo>> getUnspentForAddress(
    String address, [
    bool? unconfirmed,
    String? unspentTxHash,
    bool? verbose,
  ]);
  Future<List<Utxo>> getUnspentForAddresses(
    List<String> addresses, [
    bool? unconfirmed,
    String? unspentTxHash,
    bool? verbose,
  ]);
}
