import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';

final logger = Logger();

class UtxoRepositoryImpl implements UtxoRepository {
  final V2Api api;
  final EsploraApi _esploraApi;

  UtxoRepositoryImpl({required this.api, required EsploraApi esploraApi})
      : _esploraApi = esploraApi;

  @override
  Future<List<Utxo>> getUnspentForAddress(String address) async {
    final esploraUtxos = await _esploraApi.getUtxosForAddress(address);

    return esploraUtxos.map((a) {
      return Utxo(
        vout: a.vout,
        height: a.status.blockHeight,
        value: a.value,
        txid: a.txid,
        address: address,
      );
    }).toList();
  }
}
