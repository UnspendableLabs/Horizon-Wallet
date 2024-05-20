import 'dart:typed_data';
import 'package:convert/convert.dart' as c;

class Seed {
  final Uint8List _seed;

  Seed(this._seed);

  String get toHex => c.hex.encode(_seed);

  Uint8List get bytes => _seed;

  // TODO: test 
  factory Seed.fromHex(String hex) {
    return Seed(c.hex.decode(hex) as Uint8List);
  }

}
