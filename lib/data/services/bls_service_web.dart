import 'dart:convert' show utf8;
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart' as convert;
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/js/bls.dart' as bls;

class BlsServiceWeb implements BlsService {
  @override
  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required String message,
    String? dst,
    String? messageHex,
  }) {
    final privateKey = bls.blsDeriveMasterSK(seed.toJS);
    final hexPayload =
        messageHex ?? convert.hex.encode(utf8.encode(message));
    final signature = bls.blsSign(hexPayload, privateKey, dst);
    final publicKey = bls.blsGetPublicKey(privateKey);
    return (signature: signature, publicKey: publicKey);
  }
}
