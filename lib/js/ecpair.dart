@JS("ecpair")
library;

import 'dart:js_interop';
import "package:uniparty/js/common.dart" as c;



extension type ECPair._(JSObject _) implements JSObject {
  external bool comppessed;
  external bool lowR;
  external c.Network network;
  external JSUint8Array privateKey;
  external JSUint8Array publicKey;
}

extension type ECPairFactory._(JSObject _) implements JSObject {
  external factory ECPairFactory(JSObject eccLib);

  // external JSObject fromPrivateKey(JSUint8List privateKey, [JSObject options]);

  external ECPair fromWIF(String wif, c.Network network);


}


@JS("networks.bitcoin")
external c.Network get bitcoin;

@JS("networks.testnet")
external c.Network get testnet;