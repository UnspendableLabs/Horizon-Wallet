import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoinjs;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/domain/repositories/config_repository.dart';

bool addressIsSegwit(String sourceAddress) {
  return sourceAddress.startsWith("bc") || sourceAddress.startsWith("tb");
}

class TransactionServiceImpl implements TransactionService {
  final Config config;

  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceImpl({required this.config});

  @override
  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap) async {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    final network = _getNetwork();

    dynamic signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

    bool isSegwit = addressIsSegwit(sourceAddress);

    bitcoinjs.Payment script;
    if (isSegwit) {
      script = bitcoinjs.p2wpkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    } else {
      script = bitcoinjs.p2pkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      var prev = utxoMap[txHash];
      if (prev != null) {
        if (isSegwit) {
          input.witnessUtxo =
              bitcoinjs.WitnessUTXO(script: script.output, value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
          final txHex = await bitcoinRepository.getTransactionHex(prev.txid);

          txHex.fold(
            (l) => throw Exception('Failed to get transaction: ${l.message}'),
            (tx) {
              input.nonWitnessUtxo =
                  Buffer.from(Uint8List.fromList(hex.decode(tx)).toJS);
              psbt.addInput(input);
            },
          );
        }
      } else {
        throw Exception('Invariant: No utxo found for txHash: $txHash');
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
      var prev = utxoMap[txHash];
      if (prev == null) {
        throw Exception('Invariant: No utxo found for txHash: $txHash');
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

  bool _isOpReturn(JSUint8Array script) {
    // OP_RETURN is represented by 0x6a
    return script.toDart.isNotEmpty && script.toDart[0] == 0x6a;
  }

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };
}
