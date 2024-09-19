import 'package:horizon/domain/entities/utxo.dart';

abstract class UtxoRepository {
  Future<List<Utxo>> getUnspentForAddress(
    String address
  );
}
