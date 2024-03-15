import 'dart:typed_data';

class KeyPair {
  Uint8List publicKey;
  String privateKey;

  KeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}
