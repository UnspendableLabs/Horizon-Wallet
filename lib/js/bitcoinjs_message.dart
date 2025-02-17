@JS('hwd.bitcoinjsMessage')
library;

import 'package:js/js.dart';
import 'dart:js_interop';
import 'package:js/js_util.dart' as js_util;
import 'package:horizon/js/buffer.dart';

extension type SignerResponse._(JSObject _) implements JSObject {
  external factory SignerResponse({Buffer signature, JSNumber recovery});
}

extension type Signer._(JSObject _) implements JSObject {
  external SignerResponse sign(Buffer hash, [Buffer? extraEntropy]);
}

extension type SignatureOptions._(JSObject _) implements JSObject {
  external SignatureOptions({JSString? segwitType, Buffer? extraEntropy});
}

@JS("magicHash")
external Buffer magicHash(String message, [String? messagePrefix]);

@JS("sign")
external Buffer sign(String message, Signer signer,
    [JSBoolean? compressed,
    JSString? messagePrefix,
    SignatureOptions? options]);

@JS("verify")
external JSBoolean verify(String message, String address, Buffer signature,
    [JSString? messagePrefix, JSBoolean? checkSegwitAlways]);

Signer createECPairSigner(JSObject ecpair) {
  final jsObj = js_util.newObject();

  final signFn = allowInterop((Buffer hash, [Buffer? extraEntropy]) {
    final signature = js_util.callMethod(ecpair, 'sign', [hash]) as Buffer;
    return SignerResponse(signature: signature, recovery: 0.toJS);
  });

  js_util.setProperty(jsObj, 'sign', signFn);

  return Signer._(jsObj);
}
