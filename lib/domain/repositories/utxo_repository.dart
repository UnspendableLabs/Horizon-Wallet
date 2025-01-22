import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<(List<Utxo>, dynamic)> getUnspentForAddress(String address,
      {bool excludeCached = false});
}
