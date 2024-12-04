@JS('bitcoin')
library;

import 'dart:js_interop';
import 'package:horizon/js/buffer.dart';

extension type WitnessUTXO._(JSObject o) implements JSObject {
  external WitnessUTXO({JSUint8Array script, int value});
}

// extension TxInput {
extension type TxInput._(JSObject _) implements JSObject {
  external JSUint8Array hash;
  external int index;
  external JSUint8Array script;
  external int sequence;
  external JSUint8Array witness;
  external WitnessUTXO? witnessUtxo;
  external Buffer? nonWitnessUtxo;
}

extension type TxOutput._(JSObject _) implements JSObject {
  external JSUint8Array script;
  external int value;
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
  // Getter for globalMap
  external GlobalMap get globalMap;
}

extension type GlobalMap._(JSObject _) implements JSObject {
  // Getter for unsignedTx
  external Transaction get unsignedTx;
}

extension type Psbt._(JSObject _) implements JSObject {
  external Psbt();

  external static Psbt fromHex(String hex);
  external String toHex();

  external Psbt addInput(TxInput input);
  external Psbt addOutput(TxOutput output);

  external void signAllInputs(JSObject signer,
      [JSArray<JSNumber> sighashTypes]);
  external void signAllInputsHD(JSObject signer);

  external void signInput(int inputIndex, JSObject keyPair,
      [JSArray<JSNumber>? sighashTypes]);

  external void finalizeAllInputs();

  external Transaction extractTransaction();

  external bool validateSignaturesOfInput(JSNumber inputIndex);

  external PsbtData get data;

  external Transaction get tx;
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
  external PaymentOptions({JSAny pubkey, JSAny network});
  // external int get a;
  // external int get b;
}

@JS('address')
extension type Address._(JSObject _) implements JSObject {
  external static String fromOutputScript(
      JSUint8Array script, JSObject network);
}
