import 'dart:typed_data';

import 'package:horizon/domain/entities/network.dart';

abstract class BlsService {
  Uint8List derivePrivateKey(Uint8List seed, {
    required Network network,
    required int accountIndex,
  });

  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required Network network,
    required int accountIndex,
    required String message,
    String? dst,
    String? messageHex,
  });
}
