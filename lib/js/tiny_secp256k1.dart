import 'dart:js_interop';

@JS("__horizon_js_bundle__.tinysecp256k1")
external JSObject get ecc;

/// Direct binding to the function at tinysecp256k1.xOnlyPointFromPoint
@JS("__horizon_js_bundle__.tinysecp256k1.xOnlyPointFromPoint")
external JSUint8Array xOnlyPointFromPoint(JSUint8Array pubkey);
