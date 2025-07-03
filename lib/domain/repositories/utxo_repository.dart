import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/address_v2.dart';

abstract class UtxoRepository {
  Future<List<Utxo>> getUnattachedForAddress(
    String address,
    HttpConfig httpConfig,
  );

  Future<(List<Utxo>, List<String>)> getUnspentForAddress(
      String address, HttpConfig httpConfig,
      {bool excludeCached = false});
}

extension UtxoRepositoryX on UtxoRepository {
  /// Returns a Map<String, Utxo> keyed by "txid:vout"
  Future<Map<String, Utxo>> getUTXOMapForAddress(
    AddressV2 address,
    HttpConfig httpConfig,
  ) async {
    final (utxos, _) = await getUnspentForAddress(
      address.address,
      httpConfig,
      excludeCached: true,
    );

    return {
      for (final utxo in utxos) "${utxo.txid}:${utxo.vout}": utxo,
    };
  }

  Future<Map<String, Utxo>> getUnattachedUTXOMapForAddress(
    AddressV2 address,
    HttpConfig httpConfig,
  ) async {
    final utxos = await getUnattachedForAddress(
      address.address,
      httpConfig,
    );

    return {
      for (final utxo in utxos) "${utxo.txid}:${utxo.vout}": utxo,
    };
  }

  /// Same as above but returns a TaskEither
  TaskEither<String, Map<String, Utxo>> getUTXOMapForAddressT({
    required AddressV2 address,
    required HttpConfig httpConfig,
  }) {
    return TaskEither.tryCatch(
      () => getUTXOMapForAddress(address, httpConfig),
      (err, _) => "Failed to get UTXO map for address ${address.address}",
    );
  }

  TaskEither<String, Map<String, Utxo>> getUnattachedUTXOMapForAddressT({
    required AddressV2 address,
    required HttpConfig httpConfig,
  }) {
    return TaskEither.tryCatch(
      () => getUnattachedUTXOMapForAddress(address, httpConfig),
      (err, _) => "Failed to get UTXO map for address ${address.address}",
    );
  }
}
