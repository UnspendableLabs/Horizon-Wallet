import "package:horizon/domain/entities/utxo.dart";

class MakeRBFResponse {
  final String txHex;
  final Map<String, List<int>> inputsByTxHash;
  final int virtualSize;
  final int adjustedVirtualSize;
  final int fee;
  MakeRBFResponse({
    required this.txHex,
    required this.virtualSize,
    required this.adjustedVirtualSize,
    required this.fee,
    required this.inputsByTxHash,
  });
}

abstract class TransactionService {
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      [List<int>? sighashTypes]);

  String signPsbtTmp(String psbtHex, String privateKey);

  String psbtToUnsignedTransactionHex(String psbtHex);

  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap);

  int getVirtualSize(String unsignedTransaction);

  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
  });

  bool validateFee(
      {required String rawtransaction,
      required int expectedFee,
      required Map<String, Utxo> utxoMap});

  int countSigOps({
    required String rawtransaction,
  });

  Future<String> constructChainAndSignTransaction(
      {required String unsignedTransaction,
      required String sourceAddress,
      required List<Utxo> utxos,
      required int btcQuantity,
      required String sourcePrivKey,
      required String destinationAddress,
      required String destinationPrivKey,
      required int fee});

  Future<MakeRBFResponse> makeRBF({
    required String txHex,
    required int oldFee,
    required int newFee,
  });
}

class TransactionServiceException implements Exception {
  final String message;
  TransactionServiceException(this.message);
}
