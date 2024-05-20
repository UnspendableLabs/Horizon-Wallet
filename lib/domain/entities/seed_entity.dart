
import 'dart:typed_data';
import 'package:convert/convert.dart' as c;

class SeedEntity {
  final Uint8List _seed;

  SeedEntity(this._seed);

  String get toHex => c.hex.encode(_seed);

  Uint8List get bytes => _seed;

  // TODO: test 
  factory SeedEntity.fromHex(String hex) {
    return SeedEntity(c.hex.decode(hex) as Uint8List);
  }

}
