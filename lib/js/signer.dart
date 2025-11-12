import "dart:js_interop";
import "./buffer.dart";

extension type Signer._(JSObject _) implements JSObject {
  external Buffer get publicKey;
  external bool get lowR;
  external Buffer sign(Buffer hash, [bool lowR]);
}
