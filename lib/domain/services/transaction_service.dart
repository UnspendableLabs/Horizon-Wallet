import "package:flutter/cupertino.dart";
import "package:horizon/domain/entities/utxo.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:fpdart/fpdart.dart';

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

class UtxoWithTransaction {
  final Utxo utxo;
  final BitcoinTx transaction;
  UtxoWithTransaction({
    required this.utxo,
    required this.transaction,
  });
}

class MakeBuyPsbtReturn {
  final String psbtHex;
  final List<int> inputsToSign;
  MakeBuyPsbtReturn({
    required this.psbtHex,
    required this.inputsToSign,
  });

  String toString() {
    return 'MakeBuyPsbtReturn(psbtHex: $psbtHex, inputsToSign: $inputsToSign)';
  }
}

abstract class TransactionService {
  String finalizePsbtAndExtractTransaction({required String psbtHex});

  String signPsbt(String psbtHex, Map<int, (String, String)> inputPrivateKeyMap,
      HttpConfig httpConfig,
      [List<int>? sighashTypes]);

  String psbtToUnsignedTransactionHex(String psbtHex);

  // TODO: this doesn't totally belong here
  String signMessage(String message, String privateKey, HttpConfig httpConfig);

  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap, HttpConfig httpConfig);

  Future<String> transactionToUnsignedPsbt(
      String unsignedTransaction,
      String privateKey,
      String sourceAddress,
      Map<String, Utxo> utxoMap,
      HttpConfig httpConfig);

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

  int countInputs({
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

  String makeSalePsbt({
    required BigInt price,
    required String source,
    required String utxoTxid,
    required int utxoVoutIndex,
    required Vout utxoVout,
    required HttpConfig httpConfig,
  });

  Future<MakeBuyPsbtReturn> makeBuyPsbt({
    required String buyerAddress,
    required String sellerAddress,
    required List<UtxoWithTransaction> utxos,
    required HttpConfig httpConfig,
    required int utxoAssetValue, // TODO: convert to JS BigInt
    required BitcoinTx sellerTransaction,
    required UtxoID sellerUtxoID,
    required int price, // TODO: convert to js BigInt
    required int change,
  });

  Future<String> embedWitnessData(
      {required String psbtHex,
      required Map<int, (String, String)> inputPrivateKeyMap,
      required Map<String, Utxo> utxoMap,
      required HttpConfig httpConfig});
}

class TransactionServiceException implements Exception {
  final String message;
  TransactionServiceException(this.message);
}

extension TransactionServiceX on TransactionService {
  TaskEither<String, MakeBuyPsbtReturn> makeBuyPsbtT({
    required String buyerAddress,
    required String sellerAddress,
    required List<UtxoWithTransaction> utxos,
    required HttpConfig httpConfig,
    required int utxoAssetValue, // TODO: convert to JS BigInt
    required BitcoinTx sellerTransaction,
    required UtxoID sellerUtxoID,
    required int price, // TODO: convert to js BigInt
    required int change,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => makeBuyPsbt(
        buyerAddress: buyerAddress,
        sellerAddress: sellerAddress,
        utxos: utxos,
        httpConfig: httpConfig,
        utxoAssetValue: utxoAssetValue,
        sellerTransaction: sellerTransaction,
        sellerUtxoID: sellerUtxoID,
        price: price,
        change: change,
      ),
      (e, _) => onError(e),
    );
  }

  Either<String, String> makeSalePsbtT({
    required BigInt price,
    required String source,
    required String utxoTxid,
    required int utxoVoutIndex,
    required Vout utxoVout,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => makeSalePsbt(
        price: price,
        source: source,
        utxoTxid: utxoTxid,
        utxoVoutIndex: utxoVoutIndex,
        utxoVout: utxoVout,
        httpConfig: httpConfig,
      ),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, String> signTransactionT({
    required String unsignedTransaction,
    required String privateKey,
    required String sourceAddress,
    required Map<String, Utxo> utxoMap,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => signTransaction(
        unsignedTransaction,
        privateKey,
        sourceAddress,
        utxoMap,
        httpConfig,
      ),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, String> constructChainAndSignTransactionT({
    required String unsignedTransaction,
    required String sourceAddress,
    required List<Utxo> utxos,
    required int btcQuantity,
    required String sourcePrivKey,
    required String destinationAddress,
    required String destinationPrivKey,
    required num fee,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => constructChainAndSignTransaction(
        unsignedTransaction: unsignedTransaction,
        sourceAddress: sourceAddress,
        utxos: utxos,
        btcQuantity: btcQuantity,
        sourcePrivKey: sourcePrivKey,
        destinationAddress: destinationAddress,
        destinationPrivKey: destinationPrivKey,
        fee: fee,
        httpConfig: httpConfig,
      ),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, MakeRBFResponse> makeRBFT({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => makeRBF(
        source: source,
        txHex: txHex,
        oldFee: oldFee,
        newFee: newFee,
        httpConfig: httpConfig,
      ),
      (e, _) => onError(e),
    );
  }

  // --- Sync methods wrapped in Either ---

  Either<String, String> signPsbtT({
    required String psbtHex,
    required Map<int, (String, String)> inputPrivateKeyMap,
    required HttpConfig httpConfig,
    List<int>? sighashTypes,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => signPsbt(psbtHex, inputPrivateKeyMap, httpConfig, sighashTypes),
      (e, _) => onError(e),
    );
  }

  Either<String, String> psbtToUnsignedTransactionHexT({
    required String psbtHex,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => psbtToUnsignedTransactionHex(psbtHex),
      (e, _) => onError(e),
    );
  }

  Either<String, String> signMessageT({
    required String message,
    required String privateKey,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => signMessage(message, privateKey, httpConfig),
      (e, _) => onError(e),
    );
  }

  Either<String, int> getVirtualSizeT({
    required String rawTransaction,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => getVirtualSize(rawTransaction),
      (e, _) => onError(e),
    );
  }

  Either<String, bool> validateBTCAmountT({
    required String rawTransaction,
    required String source,
    required int expectedBTC,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => validateBTCAmount(
        rawtransaction: rawTransaction,
        source: source,
        expectedBTC: expectedBTC,
        httpConfig: httpConfig,
      ),
      (e, _) => onError(e),
    );
  }

  Either<String, bool> validateFeeT({
    required String rawTransaction,
    required int expectedFee,
    required Map<String, Utxo> utxoMap,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => validateFee(
        rawtransaction: rawTransaction,
        expectedFee: expectedFee,
        utxoMap: utxoMap,
      ),
      (e, _) => onError(e),
    );
  }

  Either<String, int> countSigOpsT({
    required String rawTransaction,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => countSigOps(rawtransaction: rawTransaction),
      (e, _) => onError(e),
    );
  }

  Either<String, int> countInputsT({
    required String rawTransaction,
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => countInputs(rawtransaction: rawTransaction),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, String> embedWitnessDataT({
    required String psbtHex,
    required Map<int, (String, String)> inputPrivateKeyMap,
    required Map<String, Utxo> utxoMap,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace callstack) onError,
  }) {
    return TaskEither.tryCatch(
      () => embedWitnessData(
        psbtHex: psbtHex,
        inputPrivateKeyMap: inputPrivateKeyMap,
        utxoMap: utxoMap,
        httpConfig: httpConfig,
      ),
      (e, callstack) => onError(e, callstack),
    );
  }

  Either<String, String> finalizePsbtAndExtractTransactionT({
    required String psbtHex,
    required String Function(Object error, StackTrace callstack) onError,
  }) {
    return Either.tryCatch(
      () => finalizePsbtAndExtractTransaction(psbtHex: psbtHex),
      (e, callstack) => onError(e, callstack),
    );
  }
}
