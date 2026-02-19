@JS('__horizon_bls__')
library;

import 'dart:js_interop';

@JS('sign')
external String blsSign(String messageHex, JSUint8Array privateKey, [String? dst]);

@JS('getPublicKey')
external String blsGetPublicKey(JSUint8Array privateKey);

@JS('deriveMasterSK')
external JSUint8Array blsDeriveMasterSK(JSUint8Array seed);

@JS('getBlsPublicKeyMinSig')
external String blsGetPublicKeyMinSig(JSUint8Array privateKey);

@JS('signBlsBinding')
external String blsSignBinding(JSUint8Array blsPrivateKey, String xOnlyPubkeyHex);

@JS('schnorrBindingHash')
external JSUint8Array blsSchnorrBindingHash(String blsPubkeyHex);
