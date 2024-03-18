import 'dart:typed_data';

class KeyPair {
  Uint8List publicKeyIntList;
  String privateKey;

  KeyPair({
    required this.publicKeyIntList,
    required this.privateKey,
  });
}
