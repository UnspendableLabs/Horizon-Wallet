import 'dart:js_interop';
import 'dart:js_util';
import 'dart:typed_data';

@JS("Buffer")
extension type Buffer._(JSObject _) implements JSObject {
  external factory Buffer.from(JSUint8Array list);

  external static bool isBuffer(JSObject obj);

  @JS('toString')
  external String toJSString([String encoding]);

  // Convert Buffer to Uint8List
  Uint8List get toDart {
    final length = getProperty<int>(this, 'length');
    final Uint8List data = Uint8List(length);
    for (int i = 0; i < length; i++) {
      data[i] = getProperty<int>(this, i.toString());
    }
    return data;
  }
}
