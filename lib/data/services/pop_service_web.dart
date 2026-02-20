import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/pop_service.dart';
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/bls.dart' as bls;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart';
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/js/bitcoin.dart' as bitcoin;

bool _btcEccInited = false;

void _ensureEcc() {
  if (_btcEccInited) return;
  bitcoin.initEccLib(tinysecp256k1js.ecc);
  _btcEccInited = true;
}

class PopServiceWeb implements PopService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  PopServiceWeb() {
    _ensureEcc();
  }

  @override
  ({String xpubkey, String blsPubkey, String schnorrSig, String blsSig})
  generatePoP({
    required Uint8List seed,
    required String taprootDerivationPath,
    required Network network,
  }) {
    final root = _bip32.fromSeed(Buffer.from(seed.toJS), network.toJS);
    final taprootChild = root.derivePath(taprootDerivationPath);

    final xpubkey = taprootChild.neutered().toBase58();

    final compressedPub = taprootChild.publicKey.toDart;
    final xOnlyBytes = compressedPub.sublist(1);
    final xOnlyHex = hex.encode(xOnlyBytes);

    final blsPrivateKey = bls.blsDeriveMasterSK(seed.toJS);

    final blsPubkey = bls.blsGetPublicKey(blsPrivateKey);

    final schnorrHash = bls.blsSchnorrBindingHash(blsPubkey);
    final schnorrSigBytes = taprootChild.signSchnorr(schnorrHash);
    final schnorrSig = hex.encode(schnorrSigBytes.toDart);

    final blsSig = bls.blsSignBinding(blsPrivateKey, xOnlyHex);

    return (
      xpubkey: xpubkey,
      blsPubkey: blsPubkey,
      schnorrSig: schnorrSig,
      blsSig: blsSig,
    );
  }
}
