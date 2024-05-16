@JS('bech32.bech32m')
library;

import 'dart:js_interop';

extension type Bech32._(JSObject _) implements JSObject {
  external String prefix;
  external JSArray<JSNumber> words;
}

@JS()
external String encode(String prefix, List<int> words);


@JS()
external Bech32 decode(String str);
