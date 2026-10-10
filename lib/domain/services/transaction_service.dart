import "dart:typed_data";

import "package:horizon/common/tapscript.dart";
import "package:horizon/domain/entities/utxo.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import "package:horizon/domain/entities/atomic_swap/atomic_swap.dart";
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

  @override
  String toString() {
    return 'MakeBuyPsbtReturn(psbtHex: $psbtHex, inputsToSign: $inputsToSign)';
  }
}

/// One input of a PSBT, as the PSBT itself describes it.
class PsbtInputDescription {
  /// The txid of the transaction the input spends, display byte order.
  final Uint8List prevoutTxid;

  /// The output the input spends, from the PSBT's `witnessUtxo`, when it has
  /// one: its script, value and address.
  final Uint8List? witnessUtxoScript;
  final int? witnessUtxoValue;
  final String? witnessUtxoAddress;

  /// The `tapLeafScript` entries: a non-empty list makes the input a taproot
  /// script path spend (e.g. the reveal of a Counterparty taproot envelope).
  final List<TapLeafScriptEntry> tapLeafScripts;

  /// The PSBT's `sighashType` for the input, when set.
  final int? sighashType;

  const PsbtInputDescription({
    required this.prevoutTxid,
    required this.witnessUtxoScript,
    required this.witnessUtxoValue,
    required this.witnessUtxoAddress,
    required this.tapLeafScripts,
    required this.sighashType,
  });
}

/// What the wallet reads from a PSBT, without the network, to decide how to
/// sign its tapscript inputs.
class PsbtDescription {
  final List<PsbtInputDescription> inputs;
  final List<Uint8List> outputScripts;

  const PsbtDescription({required this.inputs, required this.outputScripts});

  /// How the wallet signs the tapscript input `index` with the key `xOnly` of
  /// the address `signerAddress` ([planTapLeafSigning]). The signing screen
  /// and the signer both call this on the same PSBT, so the reveal the user
  /// is shown is the one that gets signed.
  TapLeafSigningPlan? planTapLeafSigningForInput(
    int index, {
    required Uint8List xOnly,
    required String signerAddress,
  }) {
    final input = inputs[index];
    return planTapLeafSigning(
      xOnly: xOnly,
      signerIsTaprootAddress: isTaprootAddress(signerAddress),
      leaves: input.tapLeafScripts,
      spentScriptPubKey: input.witnessUtxoScript,
      outputScripts: outputScripts,
      firstInputTxid: inputs.first.prevoutTxid,
      inputCount: inputs.length,
      inputSighashType: input.sighashType,
    );
  }
}

abstract class TransactionService {
  String finalizePsbtAndExtractTransaction({required String psbtHex});

  /// Signs the inputs of `inputPrivateKeyMap` (input index to the signing
  /// address and its private key). A leaf that reveals a Counterparty
  /// message is signed only when its `TapLeaf` hash (hex) is in
  /// `approvedRevealLeafHashes`: the user was shown that message.
  String signPsbt(String psbtHex, Map<int, (String, String)> inputPrivateKeyMap,
      HttpConfig httpConfig,
      [List<int>? sighashTypes,
      Set<String> approvedRevealLeafHashes = const {}]);

  String psbtToUnsignedTransactionHex(String psbtHex);

  /// The inputs and outputs of a PSBT, as the PSBT describes them.
  PsbtDescription describePsbt(String psbtHex, HttpConfig httpConfig);

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

  Future<String> makeSalePsbt({
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

  Future<MakeBuyPsbtReturn> makeMultiBuyPsbt({
    required HttpConfig httpConfig,
    required String buyerAddress,
    required List<(AtomicSwap, BitcoinTx)> swapsWithSellerTransactions,
    required List<UtxoWithTransaction> utxosWithBuyerTransactions,
    required double feeRate,
    required int royaltyAmount,
    String? royaltyAddress,
    String? detachData,
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
  TaskEither<String, MakeBuyPsbtReturn> makeMultiBuyPsbtT({
    required HttpConfig httpConfig,
    required String buyerAddress,
    required List<(AtomicSwap, BitcoinTx)> swapsWithSellerTransactions,
    required List<UtxoWithTransaction> utxosWithBuyerTransactions,
    required double feeRate,
    required int royaltyAmount,
    String? royaltyAddress,
    String? detachData,
    required String Function(Object error, StackTrace st) onError,
  }) {
    return TaskEither.tryCatch(
      () => makeMultiBuyPsbt(
        httpConfig: httpConfig,
        buyerAddress: buyerAddress,
        swapsWithSellerTransactions: swapsWithSellerTransactions,
        utxosWithBuyerTransactions: utxosWithBuyerTransactions,
        feeRate: feeRate,
        royaltyAmount: royaltyAmount,
        royaltyAddress: royaltyAddress,
        detachData: detachData,
      ),
      (e, st) => onError(e, st),
    );
  }

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

  TaskEither<String, String> makeSalePsbtT({
    required BigInt price,
    required String source,
    required String utxoTxid,
    required int utxoVoutIndex,
    required Vout utxoVout,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
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
    Set<String> approvedRevealLeafHashes = const {},
    required String Function(Object error) onError,
  }) {
    return Either.tryCatch(
      () => signPsbt(psbtHex, inputPrivateKeyMap, httpConfig, sighashTypes,
          approvedRevealLeafHashes),
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
