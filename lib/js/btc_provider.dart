import 'dart:js_interop';

@JS("window.btc_providers")
external List<JSObject> get btcProviders;

extension type BtcProvider._(JSObject _) implements Object {
  external String get id;
  external String get name;
  external String get icon;

  external factory BtcProvider({String id, String name, String icon});
}

