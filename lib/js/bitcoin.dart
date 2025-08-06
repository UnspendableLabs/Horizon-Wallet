@JS('__horizon_js_bundle__.bitcoinjs')
library;

import 'dart:js_interop';
import 'package:horizon/js/buffer.dart';
import "./signer.dart";

extension type WitnessUTXO._(JSObject o) implements JSObject {
  external WitnessUTXO({Buffer script, int value});
}

// extension TxInput {
extension type TxInput._(JSObject _) implements JSObject {
  external factory TxInput.make({
    Buffer hash,
    int index,
    JSUint8Array? script,
    int? sequence,
    JSUint8Array? witness,
    WitnessUTXO? witnessUtxo,
    Buffer? nonWitnessUtxo,
    int? sighashType,
  });

  external Buffer hash;
  external int index;
  external JSUint8Array script;
  external int sequence;
  external JSUint8Array witness;
  external WitnessUTXO? witnessUtxo;
  external Buffer? nonWitnessUtxo;
  external int? sighashType;
}

extension type TxOutput._(JSObject _) implements JSObject {
  external factory TxOutput.make({
    JSUint8Array? script,
    int? value,
    String address,
  });

  external JSUint8Array script;
  external int value;
  external String address;
}

extension type Transaction._(JSObject _) implements JSObject {
  external static Transaction fromHex(String hex);

  external JSArray<TxInput> ins;
  external JSArray<TxOutput> outs;
  external String toHex();
  external int virtualSize();
  external bool hasWitnesses();

  external Buffer toBuffer([JSAny? initialBuffer, JSNumber? initialOffset]);
}

extension type PsbtData._(JSObject _) implements JSObject {
  external GlobalMap get globalMap;
}

extension type GlobalMap._(JSObject _) implements JSObject {
  external Transaction get unsignedTx;
}

extension type PsbtCache._(JSObject _) implements JSObject {
  @JS("__TX")
  external Transaction get tx;

  @JS("__FEE")
  external int get fee;
}



extension type PsbtOptions._(JSObject o) implements JSObject {
  external PsbtOptions({ JSAny network });
}

extension type Psbt._(JSObject _) implements JSObject {
  // chat there is somthing wrong with this binding. o
  // the js equivalent suold be  new Psbt({ network: networkValue })

  external factory Psbt(PsbtOptions options);

  external static Psbt fromHex(String hex);
  external String toHex();

  external Psbt addInput(TxInput input);
  external Psbt addOutput(TxOutput output);

  external void signAllInputs(Signer signer, [JSArray<JSNumber> sighashTypes]);
  external void signAllInputsHD(Signer signer);

  external void signInput(int inputIndex, Signer keyPair,
      [JSArray<JSNumber>? sighashTypes]);

  external void finalizeAllInputs();

  external Transaction extractTransaction();

  external bool validateSignaturesOfInput(JSNumber inputIndex);

  external PsbtData get data;

  external int getFee();

  external int get inputCount;

  @JS("__CACHE")
  external PsbtCache get cache;
}

extension type Payment._(JSObject _) implements JSObject {
  external Payment(String network, JSUint8Array pubkey);
  external String network;
  external JSUint8Array pubkey;
  external JSUint8Array output;
  external String address;
}

@JS("payments.p2wpkh")
external Payment p2wpkh(JSObject options);

@JS("payments.p2pkh")
external Payment p2pkh(JSObject payment);

extension type PaymentOptions._(JSObject o) implements JSObject {
  external PaymentOptions({Buffer pubkey, JSAny network});
  // external int get a;
  // external int get b;
}

@JS('address')
extension type Address._(JSObject _) implements JSObject {
  external static String fromOutputScript(
      JSUint8Array script, JSObject network);
}
