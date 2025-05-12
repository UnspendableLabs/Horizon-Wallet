import "package:horizon/domain/entities/utxo.dart";
import "package:horizon/domain/entities/http_config.dart";

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
      HttpConfig httpConfig,
      [List<int>? sighashTypes]);

  String psbtToUnsignedTransactionHex(String psbtHex);

  // TODO: this doesn't totally belong here
  String signMessage(String message, String privateKey, HttpConfig httpConfig);

  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap, HttpConfig httpConfig);

  int getVirtualSize(String unsignedTransaction);

  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
    required HttpConfig httpConfig,
  });

  bool validateFee(
      {required String rawtransaction,
      required int expectedFee,
      required Map<String, Utxo> utxoMap});

  int countSigOps({
    required String rawtransaction,
  });

  Future<String> constructChainAndSignTransaction({
    required String unsignedTransaction,
    required String sourceAddress,
    required List<Utxo> utxos,
    required int btcQuantity,
    required String sourcePrivKey,
    required String destinationAddress,
    required String destinationPrivKey,
    required num fee,
    required HttpConfig httpConfig,
  });

  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
    required HttpConfig httpConfig,
  });
}

class TransactionServiceException implements Exception {
  final String message;
  TransactionServiceException(this.message);
}
