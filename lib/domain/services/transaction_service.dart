import "package:horizon/api/v2_api.dart" as v2_api;

abstract class TransactionService {
  Future<String> signTransaction(
      String unsignedTransaction, String privateKey, String sourceAddress, Map<String, v2_api.UTXO> utxoMap);

}
