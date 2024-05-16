@JS("ecpair")
library;

import 'dart:js_interop';

extension type Bip32._(JSObject _) implements JSObject {
  external int  public;
  external int  private;
}

extension type Network._(JSObject _) implements JSObject {
  external String bech32;
  external Bip32 bip32;
  external String messagePrefix;
  external int pubKeyHash;
  external int scriptHash;
  external String wif;
}


extension type ECPair._(JSObject _) implements JSObject {
  external bool comppessed;
  external bool lowR;
  external Network network;
  external JSUint8Array privateKey;
  external JSUint8Array publicKey;
}

extension type ECPairFactory._(JSObject _) implements JSObject {
  external factory ECPairFactory(JSObject eccLib);

  // external JSObject fromPrivateKey(JSUint8List privateKey, [JSObject options]);

  external ECPair fromWIF(String wif, Network network);


}


@JS("networks.bitcoin")
external Network get bitcoin;

@JS("networks.testnet")
external Network get testnet;
