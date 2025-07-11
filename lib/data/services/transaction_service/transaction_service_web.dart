import 'dart:js_interop';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoinjs;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/horizon_utils.dart' as horizon_utils;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/js/bitcoinjs_message.dart' as bitcoinMessage;
import 'package:horizon/presentation/common/shared_util.dart';
import 'dart:math';

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

class TransactionServiceWeb implements TransactionService {
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceWeb();

  @override
  MakeBuyPsbtReturn makeBuyPsbt({
    required String buyerAddress,
    required String sellerAddress,
    required List<UtxoWithTransaction> utxos,
    required HttpConfig httpConfig,
    required int utxoAssetValue, // TODO: convert to JS BigInt
    required BitcoinTx sellerTransaction,
    required int sellerVout,
    required int price, // TODO: convert to js BigInt
    required int change,
  }) {
    if (utxos.isEmpty) {
      throw TransactionServiceException('No UTXOs provided');
    }

    List<int> inputsToSign = [0];
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt(bitcoinjs.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    Utxo firstUtxo = utxos.first.utxo;
    BitcoinTx firstUtxoTransaction = utxos.first.transaction;
    Vout firstVout = firstUtxoTransaction.vout[firstUtxo.vout];

    // add first buyter input

    psbt.addInput(bitcoinjs.TxInput.make(
      sighashType: SIGHASH_ALL,
      hash: Buffer.from(
          Uint8List.fromList(HEX.decode(firstUtxo.txid).reversed.toList())
              .toJS),
      index: firstUtxo.vout,
      witnessUtxo: bitcoinjs.WitnessUTXO(
        script: Buffer.from(
            Uint8List.fromList(HEX.decode(firstVout.scriptpubkey)).toJS),
        value: firstUtxo.value,
      ),
    ));

    //buy output to ensure transfer of asset

    psbt.addOutput(bitcoinjs.TxOutput.make(
      address: buyerAddress,
      value: utxoAssetValue.toInt(),
    ));

    // add unsigned seller input
    final sellerInput = sellerTransaction.vout[sellerVout];
    psbt.addInput(bitcoinjs.TxInput.make(
      hash: Buffer.from(Uint8List.fromList(
              HEX.decode(sellerTransaction.txid).reversed.toList())
          .toJS),
      index: sellerVout,
      witnessUtxo: bitcoinjs.WitnessUTXO(
        script: Buffer.from(
            Uint8List.fromList(HEX.decode(sellerInput.scriptpubkey)).toJS),
        value: sellerInput.value,
      ),
    ));

    // add unsigned seller output ( to cover price )

    print("what the hell is up with price here??");
    print("price ${price.toInt()}");
    psbt.addOutput(bitcoinjs.TxOutput.make(
      address: sellerAddress,
      value: price.toInt(),
    ));

    for (final utxoWithTransaction in utxos.skip(1)) {
      final utxo = utxoWithTransaction.utxo;
      final transaction = utxoWithTransaction.transaction;
      psbt.addInput(bitcoinjs.TxInput.make(
        hash: Buffer.from(
            Uint8List.fromList(HEX.decode(transaction.txid).reversed.toList())
                .toJS),
        index: utxo.vout,
        witnessUtxo: bitcoinjs.WitnessUTXO(
          script: Buffer.from(Uint8List.fromList(
                  HEX.decode(transaction.vout[utxo.vout].scriptpubkey))
              .toJS),
          value: utxo.value,
        ),
      ));

      inputsToSign.add(psbt.inputCount);
    }

    // change output

    if (change >= 546) {
      psbt.addOutput(
        bitcoinjs.TxOutput.make(address: buyerAddress, value: change),
      );
    }

    return MakeBuyPsbtReturn(
      psbtHex: psbt.toHex(),
      inputsToSign: inputsToSign,
    );
  }

  @override
  String makeSalePsbt({
    required BigInt price,
    required String source,
    required String utxoTxid,
    required int utxoVoutIndex,
    required Vout utxoVout,
    required HttpConfig httpConfig,
  }) {
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt(bitcoinjs.PsbtOptions(
      network: httpConfig.network.toJS,
    ));
    final input = bitcoinjs.TxInput.make(
        sighashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
        hash: Buffer.from(
            Uint8List.fromList(HEX.decode(utxoTxid).reversed.toList()).toJS),
        index: utxoVoutIndex,
        witnessUtxo: bitcoinjs.WitnessUTXO(
          script: Buffer.from(
              Uint8List.fromList(HEX.decode(utxoVout.scriptpubkey)).toJS),
          value: utxoVout.value,
        ));

    final output = bitcoinjs.TxOutput.make(
      address: source,
      // TODO: be more paranoid about BigInt conversion
      value: price.toInt(),
    );

    psbt.addInput(input);
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

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt(bitcoinjs.PsbtOptions(
      network: httpConfig.network.toJS,
    ));
    bitcoinjs.Transaction transaction = bitcoinjs.Transaction.fromHex(txHex);

    Map<String, List<int>> txHashToInputsMap = {};
    for (bitcoinjs.TxInput input in transaction.ins.toDart) {
      psbt.addInput(input);

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      txHashToInputsMap[txHash] = txHashToInputsMap[txHash] ?? [];

      txHashToInputsMap[txHash]!.add(input.index);
    }

    // We assume that the last output is change output.

    int lastOutIndex = transaction.outs.toDart.length - 1;

    final lastOut = transaction.outs.toDart[lastOutIndex];

    final lastOutAddress = bitcoinjs.Address.fromOutputScript(
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
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      HttpConfig httpConfig,
      [List<int>? sighashTypes]) {
    print("before");

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt.fromHex(psbtHex);

    print(sighashTypes);

    print("aftre");
    print(psbt);

    for (final entry in inputPrivateKeyMap.entries) {
      final index = entry.key;
      final privateKey = entry.value;

      Buffer privKeyJS =
          Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

      final signer =
          ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

      psbt.signInput(
          index, signer, sighashTypes?.map((e) => e.toJS).toList().toJS);
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
  Future<String> signTransaction(
      String unsignedTransaction,
      String privateKey,
      String sourceAddress,
      Map<String, Utxo> utxoMap,
      HttpConfig httpConfig) async {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt(bitcoinjs.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    dynamic signer =
        ecpairFactory.fromPrivateKey(privKeyJS, httpConfig.network.toJS);

    bool isSourceSegwit = addressIsSegwit(sourceAddress);

    bitcoinjs.Payment script;
    if (isSourceSegwit) {
      script = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    } else {
      script = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: signer.publicKey, network: httpConfig.network.toJS));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());
      final txHashKey = "$txHash:${input.index}";

      var prev = utxoMap[txHashKey];
      if (prev != null) {
        if (isSourceSegwit) {
          input.witnessUtxo = bitcoinjs.WitnessUTXO(
              script: Buffer.from(script.output), value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
          final txHex = await bitcoinRepository.getTransactionHex(
              txid: prev.txid, httpConfig: httpConfig);

          input.nonWitnessUtxo =
              Buffer.from(Uint8List.fromList(hex.decode(txHex)).toJS);
          psbt.addInput(input);
        }
      } else {
        throw TransactionServiceException(
            'Could not find output at $txHashKey');
      }
    }

    for (var i = 0; i < transaction.outs.toDart.length; i++) {
      bitcoinjs.TxOutput output = transaction.outs.toDart[i];
      psbt.addOutput(output);
    }

    psbt.signAllInputs(signer);

    psbt.finalizeAllInputs();

    bitcoinjs.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();
    return txHex;
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

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
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(rawtransaction);

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
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(rawtransaction);

    int actualBTC = 0;
    for (final output in transaction.outs.toDart) {
      if (_isOpReturn(output.script)) {
        continue;
      }
      final address = bitcoinjs.Address.fromOutputScript(
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
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(rawtransaction);
    return horizon_utils.countSigOps(transaction);
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

    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt(bitcoinjs.PsbtOptions(
      network: httpConfig.network.toJS,
    ));

    // first add the OP_RETURN output
    bitcoinjs.TxOutput output = transaction.outs.toDart[0];
    psbt.addOutput(output);

    Buffer sourcePrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(sourcePrivKey)).toJS);
    Buffer destinationPrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(destinationPrivKey)).toJS);

    // second, add the output to send the btc to the destination address
    dynamic destinationSigner = ecpairFactory.fromPrivateKey(
        destinationPrivKeyJS, httpConfig.network.toJS);

    final destinationIsSegwit = addressIsSegwit(destinationAddress);

    bitcoinjs.Payment destinationScript;
    if (destinationIsSegwit) {
      destinationScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: destinationSigner.publicKey,
          network: httpConfig.network.toJS));
    } else {
      throw TransactionServiceException(
          'Cannot chain transaction with non-segwit destination address');
    }

    psbt.addOutput(({'script': destinationScript.output, 'value': btcQuantity})
        .jsify() as bitcoinjs.TxOutput);

    // next add the inputs
    dynamic sourceSigner =
        ecpairFactory.fromPrivateKey(sourcePrivKeyJS, httpConfig.network.toJS);

    bitcoinjs.Payment sourceScript;
    if (sourceIsSegwit) {
      sourceScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    } else {
      sourceScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    }

    final targetValue = output.value + btcQuantity + fee;
    int inputSetValue = 0;

    // Keep track of used UTXOs by their txid
    Set<String> usedTxIds = {};

    // First, add all inputs from the original transaction (the counterparty api requires the vins from the composed transaction)
    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];
      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      var prev = utxos.firstWhereOrNull((utxo) => utxo.txid == txHash);
      if (prev != null) {
        if (addressIsSegwit(prev.address)) {
          input.witnessUtxo = bitcoinjs.WitnessUTXO(
              script: Buffer.from(sourceScript.output), value: prev.value);
        } else {
          input.script = sourceScript.output;
          final txHex = await bitcoinRepository.getTransactionHex(
              txid: prev.txid, httpConfig: httpConfig);

          input.nonWitnessUtxo =
              Buffer.from(Uint8List.fromList(hex.decode(txHex)).toJS);
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

      bitcoinjs.Payment inputScript;
      if (addressIsSegwit(utxo.address)) {
        inputScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
            pubkey: signer.publicKey, network: httpConfig.network.toJS));
      } else {
        inputScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
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
        final txHex = await bitcoinRepository.getTransactionHex(
            txid: utxo.txid, httpConfig: httpConfig);

        txInput['nonWitnessUtxo'] =
            Buffer.from(Uint8List.fromList(hex.decode(txHex)).toJS);
      }

      psbt.addInput(txInput.jsify() as bitcoinjs.TxInput);
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
    bitcoinjs.Payment changeScript;
    if (sourceIsSegwit) {
      changeScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    } else {
      changeScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: httpConfig.network.toJS));
    }

    // Add change output
    psbt.addOutput(({'script': changeScript.output, 'value': changeAmount})
        .jsify() as bitcoinjs.TxOutput);

    psbt.signAllInputs(sourceSigner);
    psbt.finalizeAllInputs();

    bitcoinjs.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();
    return txHex;
  }

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) {
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt.fromHex(psbtHex);

    // Access the unsigned transaction from the global map
    bitcoinjs.Transaction tx = psbt.data.globalMap.unsignedTx;

    // Get the serialized transaction buffer
    Buffer txBuffer = tx.toBuffer();

    // Convert the buffer to Uint8List
    Uint8List txBytes = txBuffer.toDart;

    // Convert the bytes to hex string
    String txHex = hex.encode(txBytes);

    return txHex;
  }
}

TransactionService createTransactionServiceImpl() => TransactionServiceWeb();
