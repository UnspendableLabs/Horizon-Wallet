import 'dart:typed_data';

import 'package:uniparty/js/bip32.dart' as bip32;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:uniparty/js/common.dart' as common;
import 'package:uniparty/js/buffer.dart';
import 'dart:js_interop';

abstract class Bip32Service<T, N> {
  T fromBase58(String inString, N network);
  T fromSeed(Uint8List seed, N network);
  // T fromPrivateKey(Uint8List) privateKey, List<int> chainCode, N network);
  // T fromPublicKey(List<int> publicKey, List<int> chainCode, N network);
}

class Bip32JSService
    implements Bip32Service<bip32.BIP32Interface, common.Network> {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  bip32.BIP32Interface fromBase58(String inString, common.Network network) {
    return _bip32.fromBase58(inString, network);
  }

  @override
  bip32.BIP32Interface fromSeed(Uint8List seed, common.Network network) {
    return _bip32.fromSeed(Buffer.from(seed.toJS), network);
  }

  // @override
  // bip32.BIP32Interface fromPrivateKey(
  //     List<int> privateKey, List<int> chainCode, common.Network network) {
  //   return _bip32.fromPrivateKey(
  //       listToUint8Array(privateKey), listToUint8Array(chainCode), network);
  // }
  //
  // @override
  // bip32.BIP32Interface fromPublicKey(
  //     List<int> publicKey, List<int> chainCode, common.Network network) {
  //   return _bip32.fromPublicKey(
  //       listToUint8Array(publicKey), listToUint8Array(chainCode), network);
  // }
}
