import 'dart:convert' show utf8;
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart' as convert;
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/js/bls.dart' as bls;

class BlsServiceWeb implements BlsService {
  @override
  Uint8List deriveMasterPrivateKey(Uint8List seed) {
    return bls.blsDeriveMasterSK(seed.toJS).toDart;
  }

  @override
  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required String message,
    String? dst,
    String? messageHex,
  }) {
    final privateKey = deriveMasterPrivateKey(seed);
    final hexPayload =
        messageHex ?? convert.hex.encode(utf8.encode(message));
    final signature = bls.blsSign(hexPayload, privateKey.toJS, dst);
    final publicKey = bls.blsGetPublicKey(privateKey.toJS);
    return (signature: signature, publicKey: publicKey);
  }
}
