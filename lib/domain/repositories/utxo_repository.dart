import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class UtxoRepository {
  Future<(List<Utxo>, List<String>)> getUnspentForAddress(
      String address, HttpConfig httpConfig,
      {bool excludeCached = false});
}
