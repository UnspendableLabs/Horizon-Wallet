import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import "package:horizon/domain/entities/http_config.dart";

const int witnessScaleFactor = 4;
const int maxPubKeysPerMultisig = 20;

class OPReturn implements BitcoinBaseAddress {
  final Script script;
  OPReturn(this.script);

  @override
  BitcoinAddressType get type => throw UnimplementedError();

  @override
  String get addressProgram => throw UnimplementedError();

  @override
  String pubKeyHash() => throw UnimplementedError();

  @override
  Script toScriptPubKey() => script;

  @override
  String toAddress(_) => "OP_RETURN";
}

class TransactionServiceNative implements TransactionService {
  final BitcoinRepository bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceNative();

  Never _unimplemented(String method) {
    throw UnimplementedError(
        '[TransactionServiceNative] $method is not implemented for native platform.');
  }

  @override
  Future<MakeRBFResponse> makeRBF({
    required HttpConfig httpConfig,
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
  }) async {
    _unimplemented('makeRBF');
    // if (newFee <= oldFee) {
    //   throw Exception('New fee must be greater than old fee');
    // }
    // final feeDelta = newFee - oldFee;
    // final BtcTransaction transaction =
    //     BtcTransaction.deserialize(BytesUtils.fromHexString(txHex));
    //
    // if (transaction.outputs.isEmpty) {
    //   throw Exception("Transaction has no outputs");
    // }
    //
    // final inputs = transaction.inputs;
    //
    // final int lastOutIndex = transaction.outputs.length - 1;
    // final TxOutput lastOut = transaction.outputs[lastOutIndex];
    //
    // String lastOutAddress =
    //     BitcoinScriptUtils.findAddressFromScriptPubKey(lastOut.scriptPubKey)
    //         .toAddress(getNetwork(config: config));
    //
    // if (lastOutAddress != source) {
    //   throw Exception('Last output does not belong to source address');
    // }
    //
    // final newValue = lastOut.amount.toInt() - feeDelta.toInt();
    // if (newValue < 0) {
    //   throw Exception('Fee increase exceeds change output');
    // }
    //
    // final outputs = <TxOutput>[...transaction.outputs.take(lastOutIndex)];
    //
    // if (newValue > 0) {
    //   outputs.add(TxOutput(
    //     amount: BigInt.from(newValue),
    //     scriptPubKey: lastOut.scriptPubKey,
    //   ));
    // }
    //
    // final newTransaction = BtcTransaction(
    //     version: transaction.version,
    //     // lockTime: transaction.lockTime,  cant set locktime
    //     inputs: inputs,
    //     outputs: outputs);
    //
    // final updatedTxHex = newTransaction.toHex();
    //
    // final virtualSize = newTransaction.getVSize();
    // final sigOps = countSigOps(rawtransaction: updatedTxHex);
    // final adjustedVirtualSize =
    //     virtualSize > sigOps * 5 ? virtualSize : sigOps * 5;
    //
    // final inputsByTxHash = <String, List<int>>{};
    // for (var input in inputs) {
    //   inputsByTxHash.putIfAbsent(input.txId, () => []).add(input.txIndex);
    // }
    //
    // return MakeRBFResponse(
    //   txHex: updatedTxHex,
    //   virtualSize: virtualSize,
    //   fee: newFee,
    //   adjustedVirtualSize: adjustedVirtualSize,
    //   inputsByTxHash: inputsByTxHash,
    // );
  }

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      HttpConfig httpConfig,
      [List<int>? sighashTypes]) {
    _unimplemented('signPsbt');
    // final psbt = Psbt.fromHex(psbtHex);
    // final builder = PsbtBuilderV0(psbt);
    //
    // for (final entry in inputPrivateKeyMap.entries) {
    //   final index = entry.key;
    //
    //   final privateKey = entry.value;
    //
    //   final signer = PsbtDefaultSigner(
    //     ECPrivate.fromHex(privateKey),
    //   );
    //
    //   builder.signInput(
    //       signer: (params) {
    //         return PsbtSignerResponse(
    //             signers: [signer],
    //             sighash: sighashTypes!.reduce((a, b) => a | b));
    //       },
    //       index: index);
    // }
    //
    // return psbt.toHex();
  }

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) {
    _unimplemented('psbtToUnsignedTransactionHex');
    // final psbt = Psbt.fromHex(psbtHex);
    //
    // final builder = PsbtBuilderV0(psbt);
    //
    // return builder.buildUnsignedTransaction().toHex();
  }

  @override
  String signMessage(String message, String privateKey, HttpConfig httpConfig) {
    _unimplemented('signMessage');
  }

  @override
  Future<String> signTransaction(
    String unsignedTransaction,
    String privateKey,
    String sourceAddress,
    Map<String, Utxo> utxoMap,
    HttpConfig httpConfig,
  ) async {
    _unimplemented('signTransaction');
    // ECPrivate priv = ECPrivate.fromHex(privateKey);
    // ECPublic pub = priv.getPublic();
    // Script script = addressIsSegwit(sourceAddress)
    //     ? pub.toSegwitAddress().toScriptPubKey()
    //     : pub.toAddress().toScriptPubKey();
    //
    // BtcTransaction transaction = BtcTransaction.deserialize(
    //     BytesUtils.fromHexString(unsignedTransaction));
    //
    // PsbtBuilderV2 psbt = PsbtBuilderV2.create();
    //
    // for (TxInput input in transaction.inputs) {
    //   final prev = utxoMap["${input.txId}:${input.txIndex}"];
    //   if (prev == null) {
    //     throw Exception("Missing UTXO for ${input.txId}:${input.txIndex}");
    //   }
    //
    //   final psbtUtxo = PsbtUtxo(
    //     utxo: BitcoinUtxo(
    //       txHash: prev.txid,
    //       vout: input.txIndex,
    //       value: BigInt.from(prev.value),
    //       scriptType: addressIsSegwit(sourceAddress)
    //           ? SegwitAddressType.p2wpkh
    //           : P2pkhAddressType.p2pkh,
    //     ),
    //     privateKeys: [priv],
    //     scriptPubKey: script,
    //   );
    //
    //   final psbtInput = PsbtTransactionInput.fromUtxo(psbtUtxo);
    //
    //   psbt.addInput(psbtInput);
    // }
    //
    // for (TxOutput output in transaction.outputs) {
    //   final isOpReturn = output.scriptPubKey.script.isNotEmpty &&
    //       output.scriptPubKey.script.first == BitcoinOpcode.opReturn.name;
    //
    //   final psbtOutput = PsbtTransactionOutput(
    //     amount: output.amount,
    //     address: isOpReturn
    //         ? OPReturn(output.scriptPubKey)
    //         : BitcoinScriptUtils.findAddressFromScriptPubKey(
    //             output.scriptPubKey),
    //   );
    //
    //   psbt.addOutput(psbtOutput);
    // }
    //
    // PsbtBtcSigner signer = PsbtDefaultSigner(priv);
    //
    // psbt.signAllInput((psbtSignerParams) {
    //   if (psbtSignerParams.scriptPubKey != script) {
    //     return null;
    //   }
    //   // assert(psbtSignerParams.address == sourceAddress);
    //   return PsbtSignerResponse(
    //       sighash: BitcoinOpCodeConst.sighashAll, signers: [signer]);
    // });
    //
    // BtcTransaction signedTransaction = psbt.finalizeAll();
    //
    // return signedTransaction.toHex();
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    final tx = BtcTransaction.deserialize(
        BytesUtils.fromHexString(unsignedTransaction));

    if (tx.hasWitness) {
      return tx.getVSize();
    } else {
      final int baseSize = tx.inputs.length * 148 + tx.outputs.length * 34 + 10;

      return baseSize;
    }
  }

  @override
  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
    required HttpConfig httpConfig,
  }) {
    _unimplemented('validateBTCAmount');
  }

  @override
  bool validateFee({
    required String rawtransaction,
    required int expectedFee,
    required Map<String, Utxo> utxoMap,
  }) {
    _unimplemented('validateFee');
  }

  @override
  int countSigOps({required String rawtransaction}) {
    final tx =
        BtcTransaction.deserialize(BytesUtils.fromHexString(rawtransaction));
    int nSigOps = 0;

    nSigOps += _getLegacySigOpCount(tx) * witnessScaleFactor;

    if (tx.inputs.isNotEmpty && _isCoinbaseInput(tx.inputs[0])) {
      return nSigOps;
    }

    for (TxWitnessInput witness in tx.witnesses) {
      if (witness.stack.isNotEmpty) {
        nSigOps += 1;
      }
    }

    return nSigOps;
  }

  bool _isCoinbaseInput(TxInput input) {
    return input.txId == "0" * 64; // coinbase txid is all zeroes in raw format
  }

  int _getLegacySigOpCount(BtcTransaction tx) {
    int count = 0;

    for (final input in tx.inputs) {
      count += _countLegacySigOps(input.scriptSig);
    }

    for (final output in tx.outputs) {
      count += _countLegacySigOps(output.scriptPubKey);
    }

    return count;
  }

  int _countLegacySigOps(Script script) {
    int count = 0;
    for (final op in script.script) {
      if (op == BitcoinOpcode.opCheckSig.name ||
          op == BitcoinOpcode.opCheckSigVerify.name) {
        count += 1;
      } else if (op == BitcoinOpcode.opCheckMultiSig.name ||
          op == BitcoinOpcode.opCheckMultiSigVerify.name) {
        count += maxPubKeysPerMultisig;
      }
    }
    return count;
  }

  @override
  Future<String> constructChainAndSignTransaction({
    required String unsignedTransaction,
    required String sourceAddress,
    required List<Utxo> utxos,
    required int btcQuantity,
    required String sourcePrivKey,
    required String destinationAddress,
    required String destinationPrivKey,
    required HttpConfig httpConfig,
    required num fee,
  }) async {
    _unimplemented('constructChainAndSignTransaction');
  }
}

TransactionService createTransactionServiceImpl() => TransactionServiceNative();
