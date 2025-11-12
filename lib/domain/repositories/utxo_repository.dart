import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';

abstract class UtxoRepository {
  Future<List<Utxo>> getUnattachedForAddress(
    String address,
    HttpConfig httpConfig,
  );

  Future<(List<Utxo>, List<UtxoID>)> getUnspentForAddress(
      String address, HttpConfig httpConfig,
      {bool excludeCached = false});

  Future<Map<String, Utxo>> getUTXOMapForAddress(
    AddressV2 address,
    HttpConfig httpConfig,
  );

  Future<Map<String, Utxo>> getUnattachedUTXOMapForAddress(
    String address,
    HttpConfig httpConfig,
  );
}
