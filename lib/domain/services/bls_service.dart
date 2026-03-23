import 'dart:typed_data';

abstract class BlsService {
  Uint8List deriveMasterPrivateKey(Uint8List seed);

  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required String message,
    String? dst,
    String? messageHex,
  });
}
