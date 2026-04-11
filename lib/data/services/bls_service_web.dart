import 'dart:convert' show utf8;
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart' as convert;
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/js/bls.dart' as bls;

class BlsServiceWeb implements BlsService {
  @override
  Uint8List derivePrivateKey(Uint8List seed, {
    required Network network,
    required int accountIndex,
  }) {
    final coinType = network.isMainnet ? 0 : 1;
    return bls.blsDeriveBlsKey(seed.toJS, coinType, accountIndex).toDart;
  }

  @override
  ({String signature, String publicKey}) signMessage({
    required Uint8List seed,
    required Network network,
    required int accountIndex,
    required String message,
    String? dst,
    String? messageHex,
  }) {
    final privateKey = derivePrivateKey(seed,
        network: network, accountIndex: accountIndex);
    final hexPayload =
        messageHex ?? convert.hex.encode(utf8.encode(message));
    final signature = bls.blsSign(hexPayload, privateKey.toJS, dst);
    final publicKey = bls.blsGetPublicKey(privateKey.toJS);
    return (signature: signature, publicKey: publicKey);
  }
}
