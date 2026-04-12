@JS('__horizon_bls__')
library;

import 'dart:js_interop';

@JS('sign')
external String blsSign(String messageHex, JSUint8Array privateKey, [String? dst]);

@JS('getPublicKey')
external String blsGetPublicKey(JSUint8Array privateKey);

@JS('deriveBlsKey')
external JSUint8Array blsDeriveBlsKey(
    JSUint8Array seed, int coinType, int account);

@JS('signBlsBinding')
external String blsSignBinding(JSUint8Array blsPrivateKey, String xOnlyPubkeyHex);

@JS('schnorrBindingHash')
external JSUint8Array blsSchnorrBindingHash(String blsPubkeyHex);
