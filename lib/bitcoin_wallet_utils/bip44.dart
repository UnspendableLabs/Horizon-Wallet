import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_wif/dart_wif.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/models/base_path.dart';
import 'package:uniparty/models/key_pair.dart';

class Bip44 {
  KeyPair createBip44KeyPairFromSeed(String seedHex, BasePath path, String network) {
    print('in createBip44KeyPairFromSeed ${DateTime.now()}');
    BIP44 node = BIP44.fromSeed(seedHex, coinType: path.coinType);
    // print('node created ${DateTime.now()}');
    final privateKeyHex = node.privateKeyHex(account: path.account, change: path.change, index: path.index);
    // print('private key hex ${DateTime.now()}');
    String publicKey = node.publicKeyHex(account: path.account, change: path.change, index: path.index);
    // print('public key hex ${DateTime.now()}');
    Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));
    // print('private key ${DateTime.now()}');
    final WIF decoded = WIF(version: _getVersion(network), privateKey: privateKey, compressed: true);
    // print('decoded ${DateTime.now()}');
    String privateKeyWif = wif.encode(decoded); // testnet: Wif.encode(239, ...
    return KeyPair(publicKeyIntList: Uint8List.fromList(hex.decode(publicKey)), privateKey: privateKeyWif);
  }

  String createBip44LegacyAddress(BIP44 node, BasePath path) {
    String address = node.address(account: path.account, change: path.change, index: path.index);
    return address;
  }

  int _getVersion(String network) {
    if (network == 'testnet') {
      return 239;
    }
    return 128; // mainnet version
  }
}
