import 'dart:js_interop';
import 'dart:typed_data';

import 'package:uniparty/bip32_bitcoin_js.dart';

class Bip32Js {
  static BIP32 generateMasterKey(Uint8List seed, Network network) {
    return BIP32.fromSeed(seed.toJS, network);
  }

  static String derivePrivateKey(BIP32 masterKey, String path) {
    var childKey = masterKey.derivePath(path);
    return childKey.toWIF();
  }

  static Uint8List derivePublicKey(BIP32 masterKey, String path) {
    var childKey = masterKey.derivePath(path);
    return childKey.publicKey.toDart;
  }

  // Example function to derive a BIP44 key pair
  static void deriveBIP44KeyPair(Uint8List seed, Network network) {
    var masterKey = generateMasterKey(seed, network);
    // Example path for the first key of the first account for Bitcoin
    String path = "m/44'/0'/0'/0/0";
    String privateKey = derivePrivateKey(masterKey, path);
    Uint8List publicKey = derivePublicKey(masterKey, path);

    print('BIP44 Private Key: $privateKey');
    print('BIP44 Public Key: $publicKey');
  }
}
