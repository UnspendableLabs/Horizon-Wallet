@JS('bitcoin')
library;

import 'dart:js_interop';




// extension TxInput {
extension type TxInput._(JSObject _) implements JSObject {
  external JSUint8Array hash;
  external int index;
  external JSUint8Array script;
  external int sequence;
  external JSUint8Array witness;
}

extension type TxOutput._(JSObject _) implements JSObject {
  external JSUint8Array script;
  external int value;
}

extension type Transaction._(JSObject _) implements JSObject {
  external static Transaction fromHex(JSString hex); // TODO just use string
  external JSArray<TxInput> ins;
  external JSArray<TxOutput> outs;
}

extension type Psbt._(JSObject _) implements JSObject {
  external Psbt(); // TODO: augment the constructor
  external Psbt addInput(TxInput input);
  external Psbt addOutput(TxOutput output);
}

extension type Payment._(JSObject _) implements JSObject {
  external Payment(String network, JSUint8Array pubkey);
  external String network; // TODO: refine type
  external JSUint8Array pubkey;
}

@JS("payments.p2wpkh")
external Payment p2wpkh(JSObject options);

@JS("payments.p2pkh")
external Payment p2pkh(Payment payment);
