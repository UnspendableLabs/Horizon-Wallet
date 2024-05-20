import 'dart:js_interop';

@JS()
@staticInterop
@anonymous
class Network {
  external factory Network({String messagePrefix, String bech32, String bip32});
}

@JS('bitcoin.bip32')
extension type BIP32._(JSObject _) implements JSObject {
  external static BIP32 fromSeed(JSUint8Array seed, Network network);
  external String toWIF();
  external JSUint8Array get publicKey;
  external BIP32 derivePath(String path);
}
