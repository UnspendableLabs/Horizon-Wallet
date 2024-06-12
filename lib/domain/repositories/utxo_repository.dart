//    final utxoResponse = await client.getUnspentUTXOs(event.sourceAddress.address, false);
import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<List<Utxo>> getUnspentForAddress(
    String address, [
    bool? unconfirmed,
    String? unspentTxHash,
    bool? verbose,
  ]);
}
