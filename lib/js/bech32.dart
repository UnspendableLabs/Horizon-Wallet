@JS('__horizon_js_bundle__.bech32.bech32')
library;

import 'dart:js_interop';

extension type Decoded._(JSObject _) implements JSObject {
  external String prefix;
  external JSArray<JSNumber> words;
}

@JS()
external String encode(String prefix, JSArray<JSNumber> words);

@JS()
external Decoded decode(String str);

@JS()
external JSArray<JSNumber> toWords(JSArray<JSNumber> bytes);
