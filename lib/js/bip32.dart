@JS("bip32")
library;

import 'dart:js_interop';
import "package:uniparty/js/common.dart" as c;
import "package:uniparty/js/buffer.dart" as b;

extension type Signer._(JSObject _) implements JSObject {
  external JSUint8Array publicKey;
  external bool lowR;
  external JSUint8Array sign(JSUint8Array hash, [bool lowR]);
  external bool verify(JSUint8Array hash, JSUint8Array signature);
  external JSUint8Array signSchnorr(JSUint8Array hash);
  external bool verifySchnorr(JSUint8Array hash, JSUint8Array signature);
}

extension type BIP32Interface._(JSObject _) implements Signer {
  external JSUint8Array chainCode;
  external c.Network network;
  external int depth;
  external int index;
  external int parentFingerprint;
  external JSUint8Array? privateKey;
  external JSUint8Array publicKey;
  external JSUint8Array identifier;
  external JSUint8Array fingerprint;
  external bool isNeutered();
  external factory BIP32Interface.neutered();
  external String toBase58();
  external String toWIF();
  external BIP32Interface derive(int index);
  external BIP32Interface deriveHardened(int index);
  external BIP32Interface derivePath(String path);
}

extension type BIP32Factory._(JSObject _) implements JSObject {
  external factory BIP32Factory(JSObject eccLib);
  external BIP32Interface fromBase58(String privatekey, [c.Network network]);
  external BIP32Interface fromPrivateKey(
      JSUint8Array privateKey, JSUint8Array chainCode,
      [c.Network network]);
  external BIP32Interface fromPublicKey(
      JSUint8Array publicKey, JSUint8Array chainCode,
      [c.Network network]);
  external BIP32Interface fromSeed(b.Buffer seed, [c.Network network]);
}
