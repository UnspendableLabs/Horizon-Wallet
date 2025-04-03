import "package:horizon/domain/entities/utxo.dart";

class MakeRBFResponse {
  final String txHex;
  final Map<String, List<int>> inputsByTxHash;
  final int virtualSize;
  final int adjustedVirtualSize;
  final num fee;
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

  String psbtToUnsignedTransactionHex(String psbtHex);

  // TODO: this doesn't totally belong here
  String signMessage(String message, String privateKey);

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
      required num fee});

  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
  });
}

class TransactionServiceException implements Exception {
  final String message;
  TransactionServiceException(this.message);
}
