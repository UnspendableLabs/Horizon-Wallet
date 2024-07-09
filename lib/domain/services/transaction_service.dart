import "package:horizon/domain/entities/utxo.dart";

abstract class TransactionService {
  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap);
}
