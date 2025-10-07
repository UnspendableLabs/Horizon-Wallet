import 'package:get_it/get_it.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/network/esplora_client_factory.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/utxo_attach_repository.dart';

class UtxoRepositoryImpl implements UtxoRepository {
  final CounterpartyClientFactory _counterpartyClientFactory =
      GetIt.I<CounterpartyClientFactory>();
  final EsploraClientFactory _esploraClientFactory;
  final UtxoAttachRepository _utxoAttachRepository;
  final CacheProvider cacheProvider;
  UtxoRepositoryImpl(
      {CounterpartyClientFactory? counterpartyClientFactory,
      UtxoAttachRepository? utxoAttachRepository,
      EsploraClientFactory? esploraClientFactory,
      required this.cacheProvider})
      : _esploraClientFactory =
            esploraClientFactory ?? GetIt.I<EsploraClientFactory>(),
        _utxoAttachRepository =
            utxoAttachRepository ?? GetIt.I<UtxoAttachRepository>();

  @override
  Future<(List<Utxo>, List<UtxoID>)> getUnspentForAddress(
      String address, HttpConfig httpConfig,
      {bool excludeCached = false}) async {
    final esploraUtxos = await _esploraClientFactory
        .getClient(httpConfig)
        .getUtxosForAddress(address);

    List<Utxo> utxos = esploraUtxos.map((a) {
      return Utxo(
        confirmed: a.status.confirmed,
        vout: a.vout,
        height: a.status.blockHeight,
        value: a.value,
        txid: a.txid,
        address: address,
      );
    }).toList();

    List<UtxoID> mempoolUTXOSWithAttachedAssets = [];

    if (excludeCached) {
      final utxoMap = {
        for (final utxo in utxos)
          UtxoID.fromString("${utxo.txid}:${utxo.vout}"): utxo
      };

      final utxosInMempool = utxos.where((utxo) => !utxo.confirmed).toList();

      for (var utxo in utxosInMempool) {
        final localAttach = await _utxoAttachRepository.getByID(
          UtxoID.fromString("${utxo.txid}:${utxo.vout}"),
        );

        if (localAttach != null) {
          print(
              "Excluding mempool UTXO with attached asset: ${utxo.txid}:${utxo.vout}");
          utxoMap.remove(UtxoID.fromString("${utxo.txid}:${utxo.vout}"));
          mempoolUTXOSWithAttachedAssets
              .add(UtxoID.fromString("${utxo.txid}:${utxo.vout}"));
        }

        utxos = utxoMap.values.toList();
      }
    }

    return (utxos, mempoolUTXOSWithAttachedAssets);
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
        confirmed: a.status.confirmed,
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
    }

    // we also have to exclude any that might be in mempool
    final unattachedMap = {
      for (final utxo in unattached) "${utxo.txid}:${utxo.vout}": utxo
    };

    for (final utxo in unattached) {
      if (!utxo.confirmed) {
        final localAttach = await _utxoAttachRepository.getByID(
          UtxoID.fromString("${utxo.txid}:${utxo.vout}"),
        );

        if (localAttach != null) {
          print(
              "Excluding mempool UTXO with attached asset: ${utxo.txid}:${utxo.vout}");
          unattachedMap.remove("${utxo.txid}:${utxo.vout}");
        }
      }
    }

    return unattachedMap.values.toList();
  }
}
