import 'dart:js_interop';

extension type Bip32._(JSObject _) implements JSObject {
  external int public;
  external int private;
}

extension type Network._(JSObject _) implements JSObject {
  external String bech32;
  external Bip32 bip32;
  external String messagePrefix;
  external int pubKeyHash;
  external int scriptHash;
  external String wif;
}
