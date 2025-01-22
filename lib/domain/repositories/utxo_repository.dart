import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<(List<Utxo>, List<String>)> getUnspentForAddress(String address,
      {bool excludeCached = false});
}
