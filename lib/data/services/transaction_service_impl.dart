import 'dart:js_interop';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoinjs;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/horizon_utils.dart' as horizon_utils;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/presentation/common/shared_util.dart';

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

class TransactionServiceImpl implements TransactionService {
  final Config config;
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceImpl({required this.config});

  @override
  Future<MakeRBFResponse> makeRBF({
    required String txHex,
    required int feeDelta,
  }) async {
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    bitcoinjs.Transaction transaction = bitcoinjs.Transaction.fromHex(txHex);

    Map<String, List<int>> txHashToInputsMap = {};
    for (bitcoinjs.TxInput input in transaction.ins.toDart) {
      psbt.addInput(input);

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      txHashToInputsMap[txHash] = txHashToInputsMap[txHash] ?? [];

      txHashToInputsMap[txHash]!.add(input.index);
    }

    // TODO: this is not reliable
    int lastOutIndex = transaction.outs.toDart.length - 1;

    final lastOut = transaction.outs.toDart[lastOutIndex];

    final newValue = lastOut.value - feeDelta;

    if (newValue < 0) {
      throw TransactionServiceException(
          'Fee increase exceeds available change');
    }

    lastOut.value = newValue;

    for (var i = 0; i < lastOutIndex; i++) {
      final output = transaction.outs.toDart[i];
      psbt.addOutput(output);
    }

    psbt.addOutput(lastOut);

    return MakeRBFResponse(
        txHex: psbt.cache.tx.toHex(), inputsByTxHash: txHashToInputsMap);
  }

  @override
  String signPsbtTmp(String psbtHex, String privateKey) {
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt.fromHex(psbtHex);

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    final network = _getNetwork();

    dynamic signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

    // # TODO: obvoiusly this is a huge hack
    psbt.signInput(0, signer);

    psbt.finalizeAllInputs();

    return psbt.extractTransaction().toHex();
  }

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      [List<int>? sighashTypes]) {
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt.fromHex(psbtHex);

    for (final entry in inputPrivateKeyMap.entries) {
      final index = entry.key;
      final privateKey = entry.value;

      Buffer privKeyJS =
          Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);
      final network = _getNetwork();

      dynamic signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

      psbt.signInput(
          index, signer, sighashTypes?.map((e) => e.toJS).toList().toJS);
    }

    return psbt.toHex();
  }

  @override
  Future<String> signTransaction(
    String unsignedTransaction,
    String privateKey,
    String sourceAddress,
    Map<String, Utxo> utxoMap,
  ) async {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    final network = _getNetwork();

    dynamic signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

    bool isSourceSegwit = addressIsSegwit(sourceAddress);

    bitcoinjs.Payment script;
    if (isSourceSegwit) {
      script = bitcoinjs.p2wpkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    } else {
      script = bitcoinjs.p2pkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      print("in txHash: $txHash");

      final txHashKey = "$txHash:${input.index}";

      var prev = utxoMap[txHashKey];
      if (prev != null) {
        if (isSourceSegwit) {
          input.witnessUtxo =
              bitcoinjs.WitnessUTXO(script: script.output, value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
          final txHex = await bitcoinRepository.getTransactionHex(prev.txid);
          txHex.fold(
            (l) => throw TransactionServiceException(
                'Failed to get transaction: ${l.message}'),
            (tx) {
              input.nonWitnessUtxo =
                  Buffer.from(Uint8List.fromList(hex.decode(tx)).toJS);
              psbt.addInput(input);
            },
          );
        }
      } else {
        throw TransactionServiceException(
            'Counld not found output at $txHashKey');
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
  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
  }) {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(rawtransaction);

    int actualBTC = 0;
    for (final output in transaction.outs.toDart) {
      if (_isOpReturn(output.script)) {
        continue;
      }
      final address =
          bitcoinjs.Address.fromOutputScript(output.script, _getNetwork())
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
      required int fee}) async {
    final sourceIsSegwit = addressIsSegwit(sourceAddress);

    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    // first add the OP_RETURN output
    bitcoinjs.TxOutput output = transaction.outs.toDart[0];
    psbt.addOutput(output);

    Buffer sourcePrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(sourcePrivKey)).toJS);
    Buffer destinationPrivKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(destinationPrivKey)).toJS);

    final network = _getNetwork();

    // second, add the output to send the btc to the destination address
    dynamic destinationSigner =
        ecpairFactory.fromPrivateKey(destinationPrivKeyJS, network);

    final destinationIsSegwit = addressIsSegwit(destinationAddress);

    bitcoinjs.Payment destinationScript;
    if (destinationIsSegwit) {
      destinationScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: destinationSigner.publicKey, network: network));
    } else {
      throw TransactionServiceException(
          'Cannot chain transaction with non-segwit destination address');
    }

    psbt.addOutput(({'script': destinationScript.output, 'value': btcQuantity})
        .jsify() as bitcoinjs.TxOutput);

    // next add the inputs
    dynamic sourceSigner =
        ecpairFactory.fromPrivateKey(sourcePrivKeyJS, network);

    bitcoinjs.Payment sourceScript;
    if (sourceIsSegwit) {
      sourceScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: network));
    } else {
      sourceScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: network));
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
              script: sourceScript.output, value: prev.value);
        } else {
          input.script = sourceScript.output;
          final txHex = await bitcoinRepository.getTransactionHex(prev.txid);
          txHex.fold(
            (l) => throw TransactionServiceException(
                'Failed to get transaction: ${l.message}'),
            (tx) {
              input.nonWitnessUtxo =
                  Buffer.from(Uint8List.fromList(hex.decode(tx)).toJS);
            },
          );
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
            pubkey: signer.publicKey, network: network));
      } else {
        inputScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
            pubkey: signer.publicKey, network: network));
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
        final txHexResult =
            await bitcoinRepository.getTransactionHex(utxo.txid);
        txHexResult.fold(
          (error) => throw TransactionServiceException(
              'Failed to get transaction: ${error.message}'),
          (txHex) {
            txInput['nonWitnessUtxo'] =
                Buffer.from(Uint8List.fromList(hex.decode(txHex)).toJS);
          },
        );
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
    int changeAmount = inputSetValue - targetValue;

    // Create payment for source address (where change goes)
    bitcoinjs.Payment changeScript;
    if (sourceIsSegwit) {
      changeScript = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: network));
    } else {
      changeScript = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: sourceSigner.publicKey, network: network));
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

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.testnet4 => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };

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
