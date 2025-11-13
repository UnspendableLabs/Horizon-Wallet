@JS('__horizon_js_bundle__.bitcoinjs')
library;

import 'dart:js_interop';
import 'package:horizon/js/buffer.dart';
import './signer.dart';

/// ---------- UTXO containers ----------

@anonymous
extension type WitnessUTXO._(JSObject o) implements JSObject {
  external WitnessUTXO({Buffer script, int value});

  external Buffer script;
}

/// ---------- PSBT Input / Output ----------

extension type Bip32Derivation._(JSObject _) implements JSObject {
  external factory Bip32Derivation({
    Buffer pubkey,
    int masterFingerprint, // 4-byte fingerprint (UInt32)
    JSArray<JSNumber> path, // BIP32 components, e.g., [84|0x80000000, 1|h, ...]
  });

  external Buffer pubkey;
  external int masterFingerprint;
  external JSArray<JSNumber> path;
}

/// Taproot specific BIP32 derivation with leaf hashes
extension type TapBip32Derivation._(JSObject _) implements JSObject {
  external factory TapBip32Derivation({
    Buffer pubkey, // x-only pubkey (32-bytes) or 33?
    int masterFingerprint,
    JSArray<JSNumber> path,
    JSArray<Buffer> leafHashes, // array of 32-byte leaf hashes
  });

  external Buffer pubkey;
  external int masterFingerprint;
  external JSArray<JSNumber> path;
  external JSArray<Buffer> leafHashes;
}

@anonymous
extension type TapLeafScript._(JSObject _) implements JSObject {
  external factory TapLeafScript({
    int leafVersion, // typically 0xc0 (192)
    Buffer script,
    Buffer controlBlock,
  });

  external int leafVersion;
  external Buffer script;
  external Buffer controlBlock;
}

extension type TapScriptSig._(JSObject _) implements JSObject {
  external factory TapScriptSig({
    Buffer pubkey, // x-only 32 bytes
    Buffer leafHash, // 32 bytes
    Buffer signature, // Schnorr signature
  });

  external Buffer pubkey;
  external Buffer leafHash;

  external Buffer signature;
}

@anonymous
extension type TxInput._(JSObject _) implements JSObject {
  external factory TxInput({
    // Common
    Buffer hash,
    int index,
    JSUint8Array? script,
    int? sequence,
    JSUint8Array? witness,
    WitnessUTXO? witnessUtxo,
    Buffer? nonWitnessUtxo,
    int? sighashType,

    // Legacy/Segwit derivations
    JSArray<Bip32Derivation>? bip32Derivation,

    // ---------- Taproot fields ----------
    Buffer? tapInternalKey, // x-only
    Buffer? tapMerkleRoot, // 32 bytes (optional, key-path)
    JSArray<TapLeafScript>? tapLeafScript, // script-path details
    JSArray<TapBip32Derivation>? tapBip32Derivation,
    JSArray<TapScriptSig>? tapScriptSig,
  });

  // Common
  external Buffer hash;
  external int index;
  external JSUint8Array script;
  external int sequence;
  external JSUint8Array witness;
  external WitnessUTXO? witnessUtxo;
  external Buffer? nonWitnessUtxo;
  external int? sighashType;

  // Derivations
  external JSArray<Bip32Derivation>? bip32Derivation;

  // Taproot
  external Buffer? tapInternalKey;
  external Buffer? tapMerkleRoot;
  external JSArray<TapLeafScript>? tapLeafScript;
  external JSArray<TapBip32Derivation>? tapBip32Derivation;
  external JSArray<TapScriptSig>? tapScriptSig;
}

@anonymous
extension type TxOutput._(JSObject _) implements JSObject {
  external factory TxOutput({
    JSUint8Array? script,
    int? value,
    String address,
  });

  external JSUint8Array script;
  external int value;
  external String address;
}

/// ---------- Transactions ----------

extension type Transaction._(JSObject _) implements JSObject {
  external static Transaction fromHex(String hex);

  external JSArray<TxInput> ins;
  external JSArray<TxOutput> outs;
  external String toHex();
  external int virtualSize();
  external bool hasWitnesses();

  external Buffer toBuffer([JSAny? initialBuffer, JSNumber? initialOffset]);
}

/// ---------- PSBT internals ----------

// Add this next to your other @anonymous structs
@anonymous
extension type PsbtInputData._(JSObject _) implements JSObject {
  external JSArray<TapLeafScript>? get tapLeafScript;
  external Buffer? get tapInternalKey; // x-only 32 bytes
  external Buffer? get tapMerkleRoot; // 32 bytes
  external WitnessUTXO? get witnessUtxo;
  external Buffer? get nonWitnessUtxo;
}

extension type PsbtData._(JSObject _) implements JSObject {
  external GlobalMap get globalMap;
  external JSArray<PsbtInputData> get inputs; // <-- add this getter
}

extension type GlobalMap._(JSObject _) implements JSObject {
  external Transaction get unsignedTx;
}

extension type PsbtCache._(JSObject _) implements JSObject {
  @JS('__TX')
  external Transaction get tx;

  @JS('__FEE')
  external int get fee;
}

extension type PsbtOptions._(JSObject o) implements JSObject {
  external factory PsbtOptions({JSAny network});
}

/// NOTE: The constructor mapping is correct: new Psbt({ network })
extension type Psbt._(JSObject _) implements JSObject {
  external factory Psbt(PsbtOptions options);

  external static Psbt fromHex(
      String hex); // you may also add fromBase64/fromBuffer if exposed
  external String toHex();

  external Psbt addInput(TxInput input);
  external Psbt addOutput(TxOutput output);

  external void signAllInputs(Signer signer, [JSArray<JSNumber> sighashTypes]);
  external void signAllInputsHD(Signer signer);

  external void signInput(int inputIndex, Signer keyPair,
      [JSArray<JSNumber>? sighashTypes]);
  external void updateInput(int index, PsbtInputUpdate patch);

  external void finalizeAllInputs();

  external void finalizeInput(int inputIndex, [JSFunction? finalizer]);

  external Transaction extractTransaction();

  external bool validateSignaturesOfInput(JSNumber inputIndex);

  external PsbtData get data;

  external int getFee();

  external int get inputCount;

  // outputCount isn't actually defined, so derive it
  int get outputCount => txOutputs.length;

  external JSArray<JSAny> get txOutputs;

  @JS('__CACHE')
  external PsbtCache get cache;
}

/// ---------- payments.* ----------

extension type Payment._(JSObject _) implements JSObject {
  // This constructor signature is not used directly with payments.p2* helpers
  external Payment(String network, JSUint8Array pubkey);
  external String network;
  external JSUint8Array pubkey;
  external JSUint8Array output;
  external String address;
}

/// P2WPKH / P2PKH remain as-is
@JS('payments.p2wpkh')
external Payment p2wpkh(JSObject options);

@JS('payments.p2pkh')
external Payment p2pkh(JSObject options);

/// Taproot (bech32m) binding
@JS('payments.p2tr')
external Payment p2tr(JSObject options);

/// Options for p2wpkh/p2pkh
extension type PaymentOptions._(JSObject o) implements JSObject {
  external factory PaymentOptions({Buffer pubkey, JSAny network});
}

/// Options for p2tr (Taproot)
extension type PaymentOptionsTaproot._(JSObject o) implements JSObject {
  external factory PaymentOptionsTaproot({
    // Key-path spend (BIP86): just internalPubkey (x-only, 32 bytes)
    Buffer internalPubkey,

    // Optional Script-tree (for script-path spends)
    JSAny? scriptTree, // shape mirrors bitcoinjs-lib (nested objects/arrays)
    Buffer? redeem, // rarely used directly; keep as JSAny/Buffer if needed

    JSAny network,
  });

  external Buffer internalPubkey;
  external JSAny? scriptTree;
  external Buffer? redeem;
  external JSAny network;
}

/// address.fromOutputScript (unchanged)
@JS('address')
extension type Address._(JSObject _) implements JSObject {
  external static String fromOutputScript(
      JSUint8Array script, JSObject network);
}

typedef StackElement = JSAny;
typedef Stack = JSArray<StackElement>;

@JS('script.compile')
external JSUint8Array scriptCompile(Stack chunks);

/// ---------- ECC init (REQUIRED for Taproot) ----------

/// Bind to `bitcoinjs.initEccLib(ecc)`
/// Pass the tiny-secp256k1 ECC module (your JS wrapper object).
@JS('initEccLib')
external void initEccLib(JSObject ecc);

@JS()
@anonymous
extension type PsbtInputUpdate._(JSObject _) implements JSObject {
  external factory PsbtInputUpdate({
    JSArray<TapLeafScript>? tapLeafScript,
    Buffer? tapMerkleRoot,
    Buffer? tapInternalKey,
  });
}

@JS('crypto.taggedHash')
external Buffer taggedHash(String tag, Buffer data);
