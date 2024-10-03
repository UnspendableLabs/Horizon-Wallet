@JS("wif")
library;

import 'dart:js_interop';

extension type WIF._(JSObject _) implements JSObject {
  external int version;
  external JSUint8Array privateKey;
  external bool compressed;
}

@JS()
external WIF decode(String wif, [int? version]);
