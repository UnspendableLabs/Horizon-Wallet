import 'dart:typed_data';

abstract class BlsService {
  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required String message,
    String? dst,
  });
}
