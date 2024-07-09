@JS("buffer")
library;

import 'dart:js_interop';

extension type Buffer._(JSObject _) implements JSObject {
  external factory Buffer.from(JSUint8Array list);
}
