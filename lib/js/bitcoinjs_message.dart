@JS('bitcoinMessage')
library;

import 'dart:js_interop';
import 'package:horizon/js/buffer.dart';

extension type SignatureOptions._(JSObject _) implements JSObject {
  external SignatureOptions({JSString? segwitType, Buffer? extraEntropy});
}

@JS("magicHash")
external Buffer magicHash(Buffer message, [Buffer? messagePrefix]);

@JS("sign")
external Buffer sign(Buffer message, Buffer privateKey,
    [JSBoolean? compressed,
    JSString? messagePrefix,
    SignatureOptions? options]);


@JS("verify")
external JSBoolean verify(Buffer message, Buffer address, Buffer signature,
    [JSString? messagePrefix, JSBoolean? checkSegwitAlways]);
