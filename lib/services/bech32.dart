import 'package:uniparty/js/bech32.dart' as bech32js;
import 'dart:js_interop';

abstract class Bech32Service<T> {
  T decode(String str);
  String encode(String prefix, List<int> words);
  List<int> toWords(List<int> bytes);
}

class Bech32JSService implements Bech32Service<bech32js.Bech32> {
  @override
  bech32js.Bech32 decode(String str) {
    return bech32js.decode(str);
  }

  @override
  String encode(String prefix, List<int> words) {
    return bech32js.encode(prefix, words.map((w) => w.toJS).toList().toJS);
  }

  @override
  List<int> toWords(List<int> bytes) {
    return bech32js
        .toWords(bytes.map((b) => b.toJS).toList().toJS)
        .toDart
        .map((n) => n.toDartInt)
        .toList();
  }
}
