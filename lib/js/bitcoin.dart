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
  external static JSNumber DEFAULT_SEQUENCE;
  external static JSNumber SIGHASH_DEFAULT;
  external static JSNumber SIGHASH_ALL;
  external static JSNumber SIGHASH_NONE;
  external static JSNumber SIGHASH_SINGLE;
  external static JSNumber SIGHASH_ANYONECANPAY;
  external static JSNumber SIGHASH_OUTPUT_MASK;
  external static JSNumber SIGHASH_INPUT_MASK;
  external static JSNumber ADVANCED_TRANSACTION_MARKER;
  external static JSNumber ADVANCED_TRANSACTION_FLAG;

  external static Transaction fromHex(String hex);

  external JSArray<TxInput> ins;
  external JSArray<TxOutput> outs;
  external String toHex();
  external int virtualSize();
  external bool hasWitnesses();

  external int addInput(JSUint8Array hash, int index,
      [int? sequence, JSUint8Array? scriptSig]);
  external int addOutput(JSUint8Array scriptPubKey, int value);
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
      [JSArray<JSNumber> sighashTypes]);

  external void finalizeAllInputs();

  external Transaction extractTransaction();

  external void signInput(int index, JSObject signer);
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
