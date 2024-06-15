import 'dart:js_interop';

import 'package:hex/hex.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/services/ecpair_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoinjs;

class TransactionServiceImpl implements TransactionService {
  ECPairService ecpairService;

  TransactionServiceImpl(this.ecpairService);
  @override
  Future<String> signTransaction(
      String unsignedTransaction, String privateKey, String sourceAddress, Map<String, Utxo> utxoMap) async {
    bitcoinjs.Transaction transaction = bitcoinjs.Transaction.fromHex(unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    print(privateKey);

    dynamic signer = ecpairService.fromWIF(privateKey, ecpairService.testnet);

    print("signer");
    print(signer);
    print(ecpairService.testnet);

    bool isSegwit = sourceAddress.startsWith("bc") || sourceAddress.startsWith("tb");

    bitcoinjs.Payment script;
    if (isSegwit) {
      script = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: ecpairService.testnet));
    } else {
      script = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: ecpairService.testnet));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      var prev = utxoMap[txHash];

      if (prev != null) {
        if (isSegwit) {
          input.witnessUtxo = bitcoinjs.WitnessUTXO(script: script.output, value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
        }
      } else {
        print(utxoMap);

        print(transaction.ins);

        // TODO: handle errors in UI
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
}
