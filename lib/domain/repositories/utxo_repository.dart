import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<(List<Utxo>, List<dynamic>?)> getUnspentForAddress(String address,
      {bool excludeCached = false});
}
