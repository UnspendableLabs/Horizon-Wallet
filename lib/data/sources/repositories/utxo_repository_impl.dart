import 'package:get_it/get_it.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/network/esplora_client_factory.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';

class UtxoRepositoryImpl implements UtxoRepository {
  final CounterpartyClientFactory _counterpartyClientFactory =
      GetIt.I<CounterpartyClientFactory>();
  final EsploraClientFactory _esploraClientFactory;
  final CacheProvider cacheProvider;
  UtxoRepositoryImpl(
      {CounterpartyClientFactory? counterpartyClientFactory,
      EsploraClientFactory? esploraClientFactory,
      required this.cacheProvider})
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

  @override
  Future<List<Utxo>> getUnattachedForAddress(
      String address, HttpConfig httpConfig,
      {int batchSize = 20}) async {
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

    final List<Utxo> unattached = [];

    for (var i = 0; i < utxos.length; i += batchSize) {
      final chunk = utxos.skip(i).take(batchSize).toList();

      final utxoIds = chunk.map((u) => '${u.txid}:${u.vout}').join(',');

      // Optionally collect results if you need them
      final Response<UtxoWithBalancesResponse> response =
          await _counterpartyClientFactory
              .getClient(httpConfig)
              .utxosWithBalances(utxoIds);

      final balances = response.result;

      if (balances == null || balances.result.isEmpty) break;

      final filteredChunk = chunk.where((utxo) {
        final key = '${utxo.txid}:${utxo.vout}';
        return balances.result[key] != true;
      });

      unattached.addAll(filteredChunk);

      // now i need to collect the utxos w/o balances here
    }

    return unattached;
  }
}
