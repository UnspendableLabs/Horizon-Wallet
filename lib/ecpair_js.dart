@JS("ecpair")
library;

import 'dart:js_interop';



extension type ECPairFactory._(JSObject _) implements JSObject {
  external factory ECPairFactory(JSObject eccLib);



  // external JSObject fromPrivateKey(JSUint8List privateKey, [JSObject options]);

  external JSObject fromPrivateKey(JSAny? privateKey);

}


@JS("networks.bitcoin")
external JSObject get bitcoin;

@JS("networks.testnet")
external JSObject get testnet;
