// ignore_for_file: constant_identifier_names

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';

import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/http_config.dart';
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoin;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/horizon_utils.dart' as horizon_utils;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/js/bitcoinjs_message.dart' as bitcoinMessage;
import 'package:horizon/presentation/common/shared_util.dart';
import 'dart:math';

import 'package:convert/convert.dart' as conv;

extension ListToJSArray<T extends JSAny?> on List<T> {
  JSArray<T> toJSArray() {
    final jsArray = JSArray<T>();
    for (final element in this) {
      jsArray.add(element);
    }
    return jsArray;
  }
}

/// Encrypts hex-encoded `data` with a hex-encoded RC4 key (`arc4KeyHex`)
/// and returns the ciphertext as a hex string.
/// Matches CryptoJS: RC4.encrypt(WordArray(data), WordArray(key))

int calculateTxBytesFeeWithRate(
  int vinsLength,
  int voutsLength,
  double feeRate, {
  int includeChangeOutput = 1,
}) {
  const int baseTxSize = 10;
  const int inSize = 68; // 180 for legacy
  const int outSize = 31; // 34 for legacy

  final int txSize = baseTxSize +
      vinsLength * inSize +
      voutsLength * outSize +
      includeChangeOutput * outSize;

  final double fee = txSize.toDouble() * feeRate;

  return fee.round();
}

int calculateOpReturnOutputSize(String dataHex) {
  // Decode hex string to bytes
  final dataBuffer = Uint8List.fromList(HEX.decode(dataHex));
  final dataLength = dataBuffer.length;

  int size = 8;

  int scriptLength = 1 +
      (dataLength < 76
          ? 1
          : dataLength < 256
              ? 2
              : 3) +
      dataLength;
  size += scriptLength < 253 ? 1 : 3; // varint for script length
  size += scriptLength; // actual script

  return size;
}

int calculateTxBytesFeeWithOpReturn(
    {required int inputCount,
    required int outputCount,
    required double feeRate,
    int opReturnSize = 0}) {
  final baseFee = calculateTxBytesFeeWithRate(
    inputCount,
    outputCount,
    feeRate,
  );

  final opReturnFee = opReturnSize.toDouble() * feeRate;

  return baseFee + opReturnFee.round();
}

// TODO: ref config
const DUST = 546;

const DEFAULT_SEQUENCE = 0xffffffff;
const SIGHASH_DEFAULT = 0x00;
const SIGHASH_ALL = 0x01;
const SIGHASH_NONE = 0x02;
const SIGHASH_SINGLE = 0x03;
const SIGHASH_ANYONECANPAY = 0x80;
const SIGHASH_OUTPUT_MASK = 0x03;
const SIGHASH_INPUT_MASK = 0x80;
const ADVANCED_TRANSACTION_MARKER = 0x00;
const ADVANCED_TRANSACTION_FLAG = 0x01;

bool isP2PKHScript({required String scriptHex}) {
  return (scriptHex.length == 25 &&
      scriptHex[0] == 0x76 && // OP_DUP
      scriptHex[1] == 0xa9 && // OP_HASH160
      scriptHex[2] == 0x14 && // Push 20 bytes
      scriptHex[23] == 0x88 && // OP_EQUALVERIFY
      scriptHex[24] == 0xac); // OP_CHECKSIG
}

Buffer hashAsBuffer(String a) {
  return Buffer.from(Uint8List.fromList(HEX.decode(a).reversed.toList()).toJS);
}

Future<bitcoin.TxInput> createInputConfig({
  required UtxoID utxo,
  required Vout vout,
  required int sighashType,
  required BitcoinRepository bitcoinRepository,
  required HttpConfig httpConfig,
}) async {
  // Vout vout = utxoTransaction.vout[utxo.vout];

  bitcoin.TxInput input = bitcoin.TxInput(
      hash: hashAsBuffer(utxo.txid),
      index: utxo.vout,
      sighashType: sighashType);

  if (isP2PKHScript(scriptHex: vout.scriptpubkey)) {
    final hexTask = handleNetworkCall(() async {
      return await bitcoinRepository.getTransactionHex(
          txid: utxo.txid, httpConfig: httpConfig);
    });

    final hexResult = await hexTask.run();
    final utxoTransactionHex = hexResult.fold(
        (error) => throw TransactionServiceException(error.message),
        (hex) => hex);

    input.nonWitnessUtxo =
        Buffer.from(Uint8List.fromList(HEX.decode(utxoTransactionHex)).toJS);
  } else {
    input.witnessUtxo = bitcoin.WitnessUTXO(
        value: vout.value,
        script: Buffer.from(
          Uint8List.fromList(HEX.decode(vout.scriptpubkey)).toJS,
        ));
  }

  return input;
}

class TransactionServiceWeb implements TransactionService {
  /// Creates a dummy UTXO for testing or placeholder purposes.
  /// Returns a map with 'hash', 'index', and 'witnessUtxo' (containing 'script' and 'value').
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final _bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceWeb();

  @override
  Future<MakeBuyPsbtReturn> makeMultiBuyPsbt({
    required HttpConfig httpConfig,
    required String buyerAddress,
    required List<(AtomicSwap, BitcoinTx)> swapsWithSellerTransactions,
    required List<UtxoWithTransaction> utxosWithBuyerTransactions,
    required num feeRate,
    required int royaltyAmount,
    String? royaltyAddress,
    String? detachData,
  }) async {
    // detachData = null;

    // can only do multi swap with P2WPKH seller inputs
    if (swapsWithSellerTransactions.length > 1) {
      for (var i = 0; i < swapsWithSellerTransactions.length; i++) {
        AtomicSwap swap = swapsWithSellerTransactions[i].$1;
        BitcoinTx sellerTransaction = swapsWithSellerTransactions[i].$2;
        UtxoID assetUtxoID = swap.assetUtxoId;
        Vout sellerOutput = sellerTransaction.vout[assetUtxoID.vout];
        if (isP2PKHScript(scriptHex: sellerOutput.scriptpubkey)) {
          throw TransactionServiceException("""
	    Multi-swap transactions do not support P2PKH seller inputs.
	    Seller input ${i + 1} (${assetUtxoID.toString()}) uses P2PKH script.
	    Please use SegWit addresses for multi-swap transactions.
	    """);
        }
      }
    }

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    List<int> inputIndices = [];
    BigInt totalInputValue = BigInt.zero;
    BigInt totalOutputValue = BigInt.zero;

    int opReturnOutputSize = 0;
    if (detachData != null) {
      opReturnOutputSize =
          calculateOpReturnOutputSize(detachData); // convert string to hex
    }

    // add primary buyer input at index 0
    // this is the destination for all assets
    final primaryUtxo = utxosWithBuyerTransactions.first.utxo;
    final primaryTx = utxosWithBuyerTransactions.first.transaction;

    bitcoin.TxInput primaryBuyerInput = await createInputConfig(
      utxo: UtxoID(
        txid: primaryUtxo.txid,
        vout: primaryUtxo.vout,
      ),
      vout: primaryTx.vout[primaryUtxo.vout],
      sighashType: SIGHASH_ALL,
      bitcoinRepository: _bitcoinRepository,
      httpConfig: httpConfig,
    );

    psbt.addInput(primaryBuyerInput);
    inputIndices.add(0);
    totalInputValue += BigInt.from(primaryUtxo.value);

    for (var i = 0; i < swapsWithSellerTransactions.length; i++) {
      AtomicSwap swap = swapsWithSellerTransactions[i].$1;
      BitcoinTx sellerTransaction = swapsWithSellerTransactions[i].$2;
      UtxoID sellerUtxoID = swap.assetUtxoId;

      bitcoin.TxInput sellerInput = await createInputConfig(
        utxo: sellerUtxoID,
        vout: sellerTransaction.vout[sellerUtxoID.vout],
        sighashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
        bitcoinRepository: _bitcoinRepository,
        httpConfig: httpConfig,
      );

      psbt.addInput(sellerInput);
      totalInputValue +=
          BigInt.from(sellerTransaction.vout[sellerUtxoID.vout].value);
    }

    if (detachData != null) {
      final encryptionKey = primaryUtxo.txid;
      JSString encryptedDetachData = horizon_utils.arc4Encrypt(
        detachData.toJS,
        encryptionKey.toJS,
      );

      final opReturnScript = bitcoin.scriptCompile([
        106.toJS,
        Buffer.from(
            Uint8List.fromList(hex.decode(encryptedDetachData.toDart)).toJS)
      ].toJS);

      psbt.addOutput(bitcoin.TxOutput(
        script: opReturnScript,
        value: 0,
      ));
    } else {
      psbt.addOutput(bitcoin.TxOutput(
        address: buyerAddress,
        value: 546,
      ));
      totalOutputValue += BigInt.from(546);
    }

    // add payment outputs to sellers
    for (var i = 0; i < swapsWithSellerTransactions.length; i++) {
      final swap = swapsWithSellerTransactions[i].$1;

      psbt.addOutput(bitcoin.TxOutput(
          address: swap.sellerAddress, value: swap.price.quantity.toInt()));

      totalOutputValue += BigInt.from(swap.price.quantity.toInt());
    }

    // add royalty payment if needed
    if (royaltyAmount >= 546 && royaltyAddress != null) {
      psbt.addOutput(bitcoin.TxOutput(
        address: royaltyAddress,
        value: royaltyAmount,
      ));

      totalOutputValue += BigInt.from(royaltyAmount);
    }

    // add additional inputs if  need to cover outputs + fees
    for (var i = 1; i < utxosWithBuyerTransactions.length; i++) {
      final utxo = utxosWithBuyerTransactions[i].utxo;
      final tx = utxosWithBuyerTransactions[i].transaction;

      final estimatedFee = calculateTxBytesFeeWithOpReturn(
          feeRate: feeRate.toDouble(),
          opReturnSize: opReturnOutputSize,
          outputCount: psbt.outputCount,
          inputCount: psbt.inputCount);

      final totalRequired = totalOutputValue + BigInt.from(estimatedFee);

      if (totalInputValue >= totalRequired) {
        break;
      }

      final additionalInput = await createInputConfig(
        utxo: UtxoID(
          txid: utxo.txid,
          vout: utxo.vout,
        ),
        vout: tx.vout[utxo.vout],
        sighashType: SIGHASH_ALL,
        bitcoinRepository: _bitcoinRepository,
        httpConfig: httpConfig,
      );

      psbt.addInput(additionalInput);
      inputIndices.add(psbt.inputCount - 1);
      totalInputValue += BigInt.from(utxo.value);
    }

    final finalEstimatedFee = calculateTxBytesFeeWithOpReturn(
        inputCount: psbt.inputCount,
        outputCount: psbt.outputCount,
        feeRate: feeRate.toDouble(),
        opReturnSize: opReturnOutputSize);
    final finalTotalRequired =
        totalOutputValue + BigInt.from(finalEstimatedFee);

    if (totalInputValue < finalTotalRequired) {
      throw TransactionServiceException(
          'Insufficient funds: total input ${totalInputValue.toString()} is less than total required ${finalTotalRequired.toString()} (outputs + fee ${finalEstimatedFee.toString()})');
    }

    final change =
        totalInputValue - totalOutputValue - BigInt.from(finalEstimatedFee);

    if (change >= BigInt.from(546)) {
      psbt.addOutput(bitcoin.TxOutput(
        address: buyerAddress,
        value: change.toInt(),
      ));
    }

    return MakeBuyPsbtReturn(
      psbtHex: psbt.toHex(),
      inputsToSign: inputIndices,
    );
  }

  @override
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
  }) async {
    if (utxos.isEmpty) {
      throw TransactionServiceException('No UTXOs provided');
    }

    Utxo firstUtxo = utxos.first.utxo;
    BitcoinTx firstUtxoTransaction = utxos.first.transaction;
    Vout firstVout = firstUtxoTransaction.vout[firstUtxo.vout];

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    // Standard structure:
    // Input[0]: Primary buyer input
    // Input[1]: Seller input (already positioned correctly from seller's PSBT)
    // Input[2+]: Additional buyer inputs
    // Output[0]: Asset to buyer
    // Output[1]: Payment to seller (already positioned correctly from seller's PSBT)
    // Output[2]: Royalty payment to artist (if royalties exist)
    // Output[3]: Change to buyer (if needed)

    List<int> inputIndices = [];

    bitcoin.TxInput primaryBuyerInput = await createInputConfig(
      utxo: UtxoID(
        txid: firstUtxo.txid,
        vout: firstUtxo.vout,
      ),
      vout: firstUtxoTransaction.vout[firstUtxo.vout],
      sighashType: SIGHASH_ALL,
      bitcoinRepository: _bitcoinRepository,
      httpConfig: httpConfig,
    );

    psbt.addInput(primaryBuyerInput);

    inputIndices.add(0);

    bitcoin.TxInput sellerInput = await createInputConfig(
      utxo: sellerUtxoID,
      vout: sellerTransaction.vout[sellerUtxoID.vout],
      sighashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
      bitcoinRepository: _bitcoinRepository,
      httpConfig: httpConfig,
    );

    psbt.addInput(sellerInput);

    //buy output to ensure transfer of asset

    psbt.addOutput(bitcoin.TxOutput(
      address: buyerAddress,
      value: utxoAssetValue.toInt(),
    ));

    // add unsigned seller output ( to cover price )
    psbt.addOutput(bitcoin.TxOutput(
      address: sellerAddress,
      value: price.toInt(),
    ));

    for (final utxoWithTransaction in utxos.skip(1)) {
      final utxo = utxoWithTransaction.utxo;
      final transaction = utxoWithTransaction.transaction;
      final input = await createInputConfig(
        utxo: UtxoID(txid: utxo.txid, vout: utxo.vout),
        vout: transaction.vout[utxo.vout],
        sighashType: SIGHASH_ALL,
        bitcoinRepository: _bitcoinRepository,
        httpConfig: httpConfig,
      );
      psbt.addInput(input);
      inputIndices.add(psbt.inputCount - 1);
    }

    // change output

    if (change >= 546) {
      psbt.addOutput(
        bitcoin.TxOutput(address: buyerAddress, value: change),
      );
    }

    return MakeBuyPsbtReturn(
      psbtHex: psbt.toHex(),
      inputsToSign: inputIndices,
    );
  }

  @override
  Future<String> makeSalePsbt({
    required BigInt price,
    required String source,
    required String utxoTxid,
    required int utxoVoutIndex,
    required Vout utxoVout,
    required HttpConfig httpConfig,
  }) async {
    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    final dummyBuyerInput = bitcoin.TxInput(
      hash: hashAsBuffer(
          "0000000000000000000000000000000000000000000000000000000000000000"),
      sighashType: SIGHASH_NONE,
      index: 0,
      witnessUtxo: bitcoin.WitnessUTXO(
        script: Buffer.from(Uint8List.fromList(
                HEX.decode('0014${List.filled(20, '00').join()}'))
            .toJS),
        value: 546, // Dummy value
      ),
    );

    final sellerInput = await createInputConfig(
      utxo: UtxoID(txid: utxoTxid, vout: utxoVoutIndex),
      vout: utxoVout,
      sighashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
      bitcoinRepository: _bitcoinRepository,
      httpConfig: httpConfig,
    );

    final dummyOutputToBeReplaceedByBuyer = bitcoin.TxOutput(
      address: source,
      // TODO: be more paranoid about BigInt conversion
      value: 0,
    );

    final output = bitcoin.TxOutput(
      address: source,
      // TODO: be more paranoid about BigInt conversion
      value: price.toInt(),
    );

    psbt.addInput(dummyBuyerInput);
    psbt.addInput(sellerInput);

    psbt.addOutput(dummyOutputToBeReplaceedByBuyer);
    psbt.addOutput(output);

    return psbt.toHex();
  }

  @override
  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
    required HttpConfig httpConfig,
  }) async {
    if (newFee <= oldFee) {
      throw TransactionServiceException('New fee must be greater than old fee');
    }

    final feeDelta = newFee - oldFee;

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));
    bitcoin.Transaction transaction = bitcoin.Transaction.fromHex(txHex);

    Map<String, List<int>> txHashToInputsMap = {};
    for (bitcoin.TxInput input in transaction.ins.toDart) {
      psbt.addInput(input);

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      txHashToInputsMap[txHash] = txHashToInputsMap[txHash] ?? [];

      txHashToInputsMap[txHash]!.add(input.index);
    }

    // We assume that the last output is change output.

    int lastOutIndex = transaction.outs.toDart.length - 1;

    final lastOut = transaction.outs.toDart[lastOutIndex];

    final lastOutAddress = bitcoin.Address.fromOutputScript(
            lastOut.script, httpConfig.network.toJS)
        .toString();

    if (lastOutAddress != source) {
      throw TransactionServiceException('Last output is not change output');
    }

    final newValue = (lastOut.value - feeDelta).ceil();

    if (newValue < 0) {
      throw TransactionServiceException(
          'Fee increase exceeds available change');
    }

    for (var i = 0; i < lastOutIndex; i++) {
      final output = transaction.outs.toDart[i];
      psbt.addOutput(output);
    }

    // only add change output if new value is > 0
    if (newValue > 0) {
      lastOut.value = newValue;
      psbt.addOutput(lastOut);
    }

    final tx = psbt.cache.tx;
    final txHex_ = tx.toHex();
    final virtualSize = tx.virtualSize();
    final sigops = countSigOps(rawtransaction: txHex);
    final adjustedVirtualSize = max(virtualSize, sigops * 5);

    return MakeRBFResponse(
        txHex: txHex_,
        virtualSize: virtualSize,
        fee: newFee,
        adjustedVirtualSize: adjustedVirtualSize,
        inputsByTxHash: txHashToInputsMap);
  }

  @override
  String signPsbt(
    String psbtHex,
    Map<int, (String, String)> inputPrivateKeyMap,
    HttpConfig httpConfig, [
    List<int>? sighashTypes,
  ]) {
    print(
        "['signPsbt'] Signing PSBT with inputPrivateKeyMap: $inputPrivateKeyMap");

    final psbt = bitcoin.Psbt.fromHex(psbtHex);
    final inputs = psbt.data.inputs;

    final sigTypes = sighashTypes?.map((e) => e.toJS).toList().toJS;

    for (final entry in inputPrivateKeyMap.entries) {
      final index = entry.key;
      final (pubHexMaybe, privHex) = entry.value;

      final privBuf =
          Buffer.from(Uint8List.fromList(conv.hex.decode(privHex)).toJS);
      final baseSigner =
          ecpairFactory.fromPrivateKey(privBuf, httpConfig.network.toJS);

      final basePub33 = baseSigner.publicKey; // compressed 33
      final basePub33Prefix = basePub33.toDart[0];
      final baseXOnly = Buffer.from(basePub33.toDart.sublist(1).toJS);

      final bitcoin.PsbtInputData inp = inputs[index];
      final hasLeaf =
          inp.tapLeafScript != null && inp.tapLeafScript!.length > 0;
      final hasTik = inp.tapInternalKey != null;

      print("hasLeaf $hasLeaf");
      print("hasTik $hasTik");

      if (hasLeaf) {
        // SCRIPT-PATH: sign with raw (untweaked) leaf key
        psbt.signInput(index, baseSigner, sigTypes);
        continue;
      } else if (hasTik) {
        final merkle = inp.tapMerkleRoot; // can be null
        late Buffer tweakData;
        if (merkle != null) {
          final xb = baseXOnly.toDart, mb = merkle.toDart;
          final concat = Uint8List(xb.length + mb.length)
            ..setAll(0, xb)
            ..setAll(xb.length, mb);
          tweakData = Buffer.from(concat.toJS);
        } else {
          tweakData = baseXOnly;
        }

        final tweak = bitcoin.taggedHash('TapTweak', tweakData);
        // secp256k1 order n
        final n = BigInt.parse(
            'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
            radix: 16);

        // Parse ints
        final d0 = BigInt.parse(conv.hex.encode(privBuf.toDart), radix: 16);
        final tw = BigInt.parse(conv.hex.encode(tweak.toDart), radix: 16);

        // BIP340 parity: if pub33 is odd (0x03), flip d
        final isOddY = basePub33Prefix == 0x03;
        final d = isOddY ? (n - d0) : d0;

        final tweaked = (d + tw) % n;
        final tweakedPriv = Buffer.from(
          Uint8List.fromList(
                  conv.hex.decode(tweaked.toRadixString(16).padLeft(64, '0')))
              .toJS,
        );

        final tweakedSigner =
            ecpairFactory.fromPrivateKey(tweakedPriv, httpConfig.network.toJS);
        psbt.signInput(index, tweakedSigner, sigTypes);
      } else {
        // legacy / segwit
        print("leg / seg signer");
        psbt.signInput(index, baseSigner, sigTypes);
      }
    }

    return psbt.toHex();
  }

  @override
  String signMessage(String message, String privateKey, HttpConfig httpConfig) {
    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    final ecpair_ =
        ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

    final bitcoinMessage.Signer signer =
        bitcoinMessage.createECPairSigner(ecpair_);

    final Buffer signatureBuf = bitcoinMessage.sign(
        message, signer, (true).toJS // evidently, needs to be compressed
        );

    final Uint8List signature = signatureBuf.toDart;

    final String b64 = base64Encode(signature);

    return b64;
  }

  @override
  Future<String> transactionToUnsignedPsbt(
      String unsignedTransaction,
      String privateKey,
      String sourceAddress,
      Map<String, Utxo> utxoMap,
      HttpConfig httpConfig) async {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(unsignedTransaction);

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    dynamic signer =
        ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

    bool isSourceSegwit = addressIsSegwit(sourceAddress);

    bitcoin.Payment script;
    if (isSourceSegwit) {
      script = bitcoin.p2wpkh(bitcoin.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    } else {
      script = bitcoin.p2pkh(bitcoin.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoin.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());
      final txHashKey = "$txHash:${input.index}";

      var prev = utxoMap[txHashKey];
      if (prev != null) {
        if (isSourceSegwit) {
          input.witnessUtxo = bitcoin.WitnessUTXO(
              script: Buffer.from(script.output), value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
          final txHex =
              await getTransactionHex(txid: prev.txid, httpConfig: httpConfig);

          input.nonWitnessUtxo =
              Buffer.from(Uint8List.fromList(hex.decode(txHex)).toJS);
          psbt.addInput(input);
        }
      } else {
        throw TransactionServiceException(
            'Could not find output at $txHashKey');
      }
    }

    return psbt.toHex();
  }

  @override
  Future<String> signTransaction(
      String unsignedTransaction,
      String privateKey,
      String sourceAddress,
      Map<String, Utxo> utxoMap,
      HttpConfig httpConfig) async {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(unsignedTransaction);

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    dynamic signer =
        ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

    bool isSourceSegwit = addressIsSegwit(sourceAddress);

    bitcoin.Payment script;
    if (isSourceSegwit) {
      script = bitcoin.p2wpkh(bitcoin.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    } else {
      script = bitcoin.p2pkh(bitcoin.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoin.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());
      final txHashKey = "$txHash:${input.index}";

      var prev = utxoMap[txHashKey];
      if (prev != null) {
        if (isSourceSegwit) {
          input.witnessUtxo = bitcoin.WitnessUTXO(
              script: Buffer.from(script.output), value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
          final txHex =
              await getTransactionHex(txid: prev.txid, httpConfig: httpConfig);
          input.nonWitnessUtxo =
              Buffer.from(Uint8List.fromList(HEX.decode(txHex)).toJS);
          psbt.addInput(input);
        }
      } else {
        throw TransactionServiceException(
            'Could not find output at $txHashKey');
      }
    }

    for (var i = 0; i < transaction.outs.toDart.length; i++) {
      bitcoin.TxOutput output = transaction.outs.toDart[i];
      psbt.addOutput(output);
    }

    psbt.signAllInputs(signer);

    psbt.finalizeAllInputs();

    bitcoin.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();
    return txHex;
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(unsignedTransaction);

    if (transaction.hasWitnesses()) {
      return transaction.virtualSize();
    } else {
      return transaction.ins.toDart.length * 148 +
          transaction.outs.toDart.length * 34 +
          10;
    }
  }

  @override
  bool validateFee(
      {required String rawtransaction,
      required int expectedFee,
      required Map<String, Utxo> utxoMap}) {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(rawtransaction);

    int ins = 0;
    int outs = 0;

    for (final input in transaction.ins.toDart) {
      var txHash = HEX.encode(input.hash.toDart.reversed.toList());
      final txHashKey = "$txHash:${input.index}";
      var prev = utxoMap[txHashKey];
      if (prev == null) {
        throw TransactionServiceException(
            'Invariant: No utxo found for txHash: $txHash');
      }
      ins += prev.value;
    }

    for (final output in transaction.outs.toDart) {
      outs += output.value;
    }

    return ins - outs == expectedFee;
  }

  @override
  bool validateBTCAmount(
      {required String rawtransaction,
      required String source,
      required int expectedBTC,
      required HttpConfig httpConfig}) {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(rawtransaction);

    int actualBTC = 0;
    for (final output in transaction.outs.toDart) {
      if (_isOpReturn(output.script)) {
        continue;
      }
      final address = bitcoin.Address.fromOutputScript(
              output.script, httpConfig.network.toJS)
          .toString();
      final amount = output.value;

      if (address != source) {
        actualBTC += amount;
      }
    }
    return actualBTC == expectedBTC;
  }

  @override
  int countSigOps({required String rawtransaction}) {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(rawtransaction);
    return horizon_utils.countSigOps(transaction);
  }

  @override
  int countInputs({required String rawtransaction}) {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(rawtransaction);

    return transaction.ins.toDart.length;
  }

  bool _isOpReturn(JSUint8Array script) {
    // OP_RETURN is represented by 0x6a
    return script.toDart.isNotEmpty && script.toDart[0] == 0x6a;
  }

  @override
  Future<String> constructChainAndSignTransaction(
      {required String unsignedTransaction,
      required String sourceAddress,
      required List<Utxo> utxos,
      required int btcQuantity,
      required String sourcePrivKey,
      required String destinationAddress,
      required String destinationPrivKey,
      required num fee,
      required HttpConfig httpConfig}) async {
    final sourceIsSegwit = addressIsSegwit(sourceAddress);

    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(unsignedTransaction);

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    // first add the OP_RETURN output
    bitcoin.TxOutput output = transaction.outs.toDart[0];
    psbt.addOutput(output);

    Buffer sourcePrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(sourcePrivKey)).toJS);
    Buffer destinationPrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(destinationPrivKey)).toJS);

    // second, add the output to send the btc to the destination address
    dynamic destinationSigner = ecpairFactory.fromPrivateKey(
        destinationPrivKeyJS, httpConfig.network.toJS);

    final destinationIsSegwit = addressIsSegwit(destinationAddress);

    bitcoin.Payment destinationScript;
    if (destinationIsSegwit) {
      destinationScript = bitcoin.p2wpkh(bitcoin.PaymentOptions(
          pubkey: destinationSigner.publicKey,
          network: httpConfig.network.toJS));
    } else {
      throw TransactionServiceException(
          'Cannot chain transaction with non-segwit destination address');
    }

    psbt.addOutput(({'script': destinationScript.output, 'value': btcQuantity})
        .jsify() as bitcoin.TxOutput);

    // next add the inputs
    dynamic sourceSigner =
        ecpairFactory.fromPrivateKey(sourcePrivKeyJS, httpConfig.network.toJS);

    bitcoin.Payment sourceScript;
    if (sourceIsSegwit) {
      sourceScript = bitcoin.p2wpkh(bitcoin.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    } else {
      sourceScript = bitcoin.p2pkh(bitcoin.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    }

    final targetValue = output.value + btcQuantity + fee;
    int inputSetValue = 0;

    // Keep track of used UTXOs by their txid
    Set<String> usedTxIds = {};

    // First, add all inputs from the original transaction (the counterparty api requires the vins from the composed transaction)
    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoin.TxInput input = transaction.ins.toDart[i];
      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      var prev = utxos.firstWhereOrNull((utxo) => utxo.txid == txHash);
      if (prev != null) {
        if (addressIsSegwit(prev.address)) {
          input.witnessUtxo = bitcoin.WitnessUTXO(
              script: Buffer.from(sourceScript.output), value: prev.value);
        } else {
          input.script = sourceScript.output;
          final txHex =
              await getTransactionHex(txid: prev.txid, httpConfig: httpConfig);
          input.nonWitnessUtxo =
              Buffer.from(Uint8List.fromList(HEX.decode(txHex)).toJS);
        }
        inputSetValue += prev.value;
        psbt.addInput(input);
        usedTxIds.add(txHash);
      } else {
        throw TransactionServiceException(
            'Insufficient funds: no utxos available');
      }
    }

    // Then add additional UTXOs as inputs if needed, skipping any that were already used. We add UTXOs until we have enough to cover the btc + fee value.
    // ignore: unused_local_variable
    int currentInputIndex = transaction.ins.toDart.length;
    for (var utxo in utxos) {
      if (inputSetValue >= targetValue) break;
      if (usedTxIds.contains(utxo.txid)) continue;

      bool isSourceInput = utxo.address == sourceAddress;
      dynamic signer = isSourceInput ? sourceSigner : destinationSigner;

      bitcoin.Payment inputScript;
      if (addressIsSegwit(utxo.address)) {
        inputScript = bitcoin.p2wpkh(bitcoin.PaymentOptions(
            pubkey: signer.publicKey, network: httpConfig.network.toJS));
      } else {
        inputScript = bitcoin.p2pkh(bitcoin.PaymentOptions(
            pubkey: signer.publicKey, network: httpConfig.network.toJS));
      }

      var txInput = {
        'hash': utxo.txid,
        'index': utxo.vout,
      };

      if (addressIsSegwit(utxo.address)) {
        // For SegWit inputs
        txInput['witnessUtxo'] = {
          'script': inputScript.output,
          'value': utxo.value,
        };
      } else {
        // For legacy inputs, fetch the full previous transaction
        // TODO: for chaining transactions, the previous transaction may not exist yet. we will need to find another way to get the full tx
        // for now, we will just throw an error if the previous transaction is not found
        final txHex =
            await getTransactionHex(txid: utxo.txid, httpConfig: httpConfig);
        txInput['nonWitnessUtxo'] =
            Buffer.from(Uint8List.fromList(HEX.decode(txHex)).toJS);
      }

      psbt.addInput(txInput.jsify() as bitcoin.TxInput);
      inputSetValue += utxo.value;
      usedTxIds.add(utxo.txid);
      currentInputIndex++;
    }

    // if we don't have enough inputs to cover the btc + fee value, throw an error
    if (inputSetValue < targetValue) {
      throw TransactionServiceException(
          'Insufficient funds: available $inputSetValue, needed $targetValue');
    }

    // change output will be targetValue - inputSetValue goes to the source address

    // Add the for change
    int changeAmount = (inputSetValue - targetValue).ceil();

    // Create payment for source address (where change goes)
    bitcoin.Payment changeScript;
    if (sourceIsSegwit) {
      changeScript = bitcoin.p2wpkh(bitcoin.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    } else {
      changeScript = bitcoin.p2pkh(bitcoin.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    }

    // Add change output
    psbt.addOutput(({'script': changeScript.output, 'value': changeAmount})
        .jsify() as bitcoin.TxOutput);

    psbt.signAllInputs(sourceSigner);
    psbt.finalizeAllInputs();

    bitcoin.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();
    return txHex;
  }

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) {
    bitcoin.Psbt psbt = bitcoin.Psbt.fromHex(psbtHex);

    // Access the unsigned transaction from the global map
    bitcoin.Transaction tx = psbt.data.globalMap.unsignedTx;

    // Get the serialized transaction buffer
    Buffer txBuffer = tx.toBuffer();

    // Convert the buffer to Uint8List
    Uint8List txBytes = txBuffer.toDart;

    // Convert the bytes to hex string
    String txHex = hex.encode(txBytes);

    return txHex;
  }

  @override
  Future<String> embedWitnessData(
      {required String psbtHex,
      required Map<int, (String, String)> inputPrivateKeyMap,
      required Map<String, Utxo> utxoMap,
      required HttpConfig httpConfig}) async {
    bitcoin.Transaction transaction =
        bitcoin.Transaction.fromHex(psbtToUnsignedTransactionHex(psbtHex));

    bitcoin.Psbt psbt = bitcoin.Psbt(bitcoin.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      final inputSignerData = inputPrivateKeyMap[i];
      if (inputSignerData == null) continue;

      final source = inputSignerData.$1;
      final privateKey = inputSignerData.$2;

      final input = transaction.ins.toDart[i];
      final txHash = HEX.encode(input.hash.toDart.reversed.toList());
      final utxoID = "$txHash:${input.index}";

      final utxo = utxoMap[utxoID];

      if (utxo == null) {
        throw TransactionServiceException('Could not find output at $utxoID');
      }

      Buffer privKeyJS =
          Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);
      dynamic signer =
          ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

      if (addressIsSegwit(source)) {
        bitcoin.Payment script = bitcoin.p2wpkh(bitcoin.PaymentOptions(
            pubkey: signer.publicKey, network: httpConfig.network.toJS));
        input.witnessUtxo = bitcoin.WitnessUTXO(
            script: Buffer.from(script.output), value: utxo.value);
        psbt.addInput(input);
      } else {
        bitcoin.Payment script = bitcoin.p2pkh(bitcoin.PaymentOptions(
            pubkey: signer.publicKey, network: httpConfig.network.toJS));
        input.script = script.output;
        final txHex =
            await getTransactionHex(txid: utxo.txid, httpConfig: httpConfig);
        input.nonWitnessUtxo =
            Buffer.from(Uint8List.fromList(HEX.decode(txHex)).toJS);

        psbt.addInput(input);
      }
    }

    for (var i = 0; i < transaction.outs.toDart.length; i++) {
      bitcoin.TxOutput output = transaction.outs.toDart[i];
      psbt.addOutput(output);
    }

    return psbt.toHex();
  }

  @override
  String finalizePsbtAndExtractTransaction({required String psbtHex}) {
    // CHAT this is telling me t

    bitcoin.Psbt psbt = bitcoin.Psbt.fromHex(psbtHex);

    psbt.finalizeAllInputs();

    bitcoin.Transaction tx = psbt.extractTransaction();

    return tx.toHex();
  }

  Future<String> getTransactionHex(
      {required String txid, required HttpConfig httpConfig}) async {
    final hexTask = handleNetworkCall(() async {
      return await _bitcoinRepository.getTransactionHex(
          txid: txid, httpConfig: httpConfig);
    });

    final hexResult = await hexTask.run();
    return hexResult.fold(
        (error) => throw TransactionServiceException(error.message),
        (hex) => hex);
  }
}

TransactionService createTransactionServiceImpl() => TransactionServiceWeb();
