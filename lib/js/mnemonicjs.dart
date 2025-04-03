import 'dart:js_interop';

@JS('__horizon_js_bundle__.mnemonicjs')
extension type Mnemonic._(JSObject _) implements JSObject {
  external Mnemonic(JSArray<JSString> words);
  external String toHex();
  external static JSArray<JSString> get words;
}
