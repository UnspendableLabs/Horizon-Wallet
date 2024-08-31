import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoinjs;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/domain/repositories/config_repository.dart';

class TransactionServiceImpl implements TransactionService {
  final Config config;

  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);

  TransactionServiceImpl({required this.config});

  @override
  Future<String> signTransaction(String unsignedTransaction, String privateKey,
      String sourceAddress, Map<String, Utxo> utxoMap) async {
    print("Signing transaction with private key: $privateKey");
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    print("Transaction: $transaction");
    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    print("Private key: $privateKey");

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    print("Private key JS: $privKeyJS");

    final network = _getNetwork();

    print("Network: $network");

    dynamic signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

    print("Signer: $signer");

    bool isSegwit =
        sourceAddress.startsWith("bc") || sourceAddress.startsWith("tb");

    print("Is segwit: $isSegwit");

    bitcoinjs.Payment script;
    if (isSegwit) {
      script = bitcoinjs.p2wpkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    } else {
      script = bitcoinjs.p2pkh(
          bitcoinjs.PaymentOptions(pubkey: signer.publicKey, network: network));
    }

    print("Script: $script");

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      print("Tx hash: $txHash");

      var prev = utxoMap[txHash];

      if (prev != null) {
        print("Prev: $prev");

        if (isSegwit) {
          input.witnessUtxo =
              bitcoinjs.WitnessUTXO(script: script.output, value: prev.value);
          psbt.addInput(input);
        } else {
          input.script = script.output;
        }
      } else {
        // TODO: handle errors in UI
        throw Exception('Invariant: No utxo found for txHash: $txHash');
      }
    }

    for (var i = 0; i < transaction.outs.toDart.length; i++) {
      bitcoinjs.TxOutput output = transaction.outs.toDart[i];

      psbt.addOutput(output);
    }

    print("PSBT: $psbt");

    psbt.signAllInputs(signer);

    print("PSBT after signing: $psbt");

    psbt.finalizeAllInputs();

    bitcoinjs.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();

    print("Tx hex: $txHex");

    return txHex;
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(unsignedTransaction);

    return transaction.virtualSize();
  }

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };
}
