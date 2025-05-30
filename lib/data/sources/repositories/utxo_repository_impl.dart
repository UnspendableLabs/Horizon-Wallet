import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';

class UtxoRepositoryImpl implements UtxoRepository {
  final V2Api api;
  final EsploraApi _esploraApi;
  final CacheProvider cacheProvider;
  UtxoRepositoryImpl(
      {required this.api,
      required EsploraApi esploraApi,
      required this.cacheProvider})
      : _esploraApi = esploraApi;

  @override
  Future<(List<Utxo>, List<String>)> getUnspentForAddress(String address,
      {bool excludeCached = false}) async {
    final esploraUtxos = await _esploraApi.getUtxosForAddress(address);

    List<Utxo> utxos = esploraUtxos.map((a) {
      return Utxo(
        vout: a.vout,
        height: a.status.blockHeight,
        value: a.value,
        txid: a.txid,
        address: address,
      );
    }).toList();

    List<String> cachedTxHashes = [];

    if (excludeCached) {
      final allCachedTxHashes = cacheProvider.getValue(address);
      if (allCachedTxHashes != null && allCachedTxHashes.isNotEmpty) {
        cachedTxHashes =
            (allCachedTxHashes as List).map((e) => e.toString()).toList();
        utxos = utxos.where((utxo) {
          return !(cachedTxHashes.contains(utxo.txid) && utxo.vout == 0);
        }).toList();
      }
    }
    return (utxos, cachedTxHashes);
  }
}
