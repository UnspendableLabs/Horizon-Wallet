import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class UtxoRepositoryImpl implements UtxoRepository {
  final V2Api api;

  UtxoRepositoryImpl({required this.api});

  @override
  Future<List<Utxo>> getUnspentForAddress(String address,
      [bool? unconfirmed, String? unspentTxHash, bool? verbose]) async {
    final response =
        await api.getUnspentUTXOs(address, unconfirmed, unspentTxHash, verbose);

    final List<Utxo> utxos = [];
    for (var a in response.result ?? []) {
      utxos.add(Utxo(
          vout: a.vout,
          height: a.height,
          value: a.value,
          confirmations: a.confirmations,
          amount: a.amount,
          txid: a.txid,
          address: address));
    }
    return utxos;
  }

  @override
  Future<List<Utxo>> getUnspentForAddresses(List<String> addresses,
      [bool? unconfirmed, String? unspentTxHash, bool? verbose]) async {
    List<Utxo> utxos = [];
    for (var address in addresses) {
      utxos.addAll(await getUnspentForAddress(
          address, unconfirmed, unspentTxHash, verbose));
    }
    return utxos;
  }
}
