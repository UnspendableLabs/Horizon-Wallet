import 'package:get_it/get_it.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/data/sources/network/esplora_client_factory.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';

class UtxoRepositoryImpl implements UtxoRepository {
  final EsploraClientFactory _esploraClientFactory;
  final CacheProvider cacheProvider;
  UtxoRepositoryImpl(
      {EsploraClientFactory? esploraClientFactory, required this.cacheProvider})
      : _esploraClientFactory =
            esploraClientFactory ?? GetIt.I<EsploraClientFactory>();

  @override
  Future<(List<Utxo>, List<String>)> getUnspentForAddress(
      String address, HttpConfig httpConfig,
      {bool excludeCached = false}) async {
    final esploraUtxos = await _esploraClientFactory
        .getClient(httpConfig)
        .getUtxosForAddress(address);

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
