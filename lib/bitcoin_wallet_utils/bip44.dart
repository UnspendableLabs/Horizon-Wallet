import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_wif/dart_wif.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/models/base_path.dart';
import 'package:uniparty/models/key_pair.dart';
import 'package:uniparty/models/wallet_node.dart';

class Bip44 {
  KeyPair createBip44KeyPairFromSeed(String seedHex, BasePath path) {
    BIP44 node = BIP44.fromSeed(seedHex, coinType: path.coinType);

    final privateKeyHex =
        node.privateKeyHex(account: path.account, change: path.change, index: path.index);

    String publicKey =
        node.publicKeyHex(account: path.account, change: path.change, index: path.index);

    Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));

    final WIF decoded = WIF(version: _getVersion(), privateKey: privateKey, compressed: true);

    String privateKeyWif = wif.encode(decoded); // testnet: Wif.encode(239, ...
    return KeyPair(
        publicKeyIntList: Uint8List.fromList(hex.decode(publicKey)), privateKey: privateKeyWif);
  }

  String createBip44LegacyAddress(BIP44 node, BasePath path) {
    String address = node.address(account: path.account, change: path.change, index: path.index);
    return address;
  }

  @Deprecated('Do not couple pub/priv key and address derivation')
  WalletNode createBip44AddressFromSeed(String seedHex, BasePath path) {
    final node = BIP44.fromSeed(seedHex, coinType: path.coinType);

    final privateKeyHex =
        node.privateKeyHex(account: path.account, change: path.change, index: path.index);

    final publicKey =
        node.publicKeyHex(account: path.account, change: path.change, index: path.index);

    final address = node.address(account: path.account, change: path.change, index: path.index);

    Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));

    final WIF decoded = WIF(version: _getVersion(), privateKey: privateKey, compressed: true);

    String key = wif.encode(decoded); // for the testnet use: Wif.encode(239, ...

    return WalletNode(address: address, publicKey: publicKey, privateKey: key, index: path.index);
  }

  int _getVersion() {
    if (dotenv.env['ENV'] == 'testnet') {
      return 239;
    }
    return 128; // mainnet version
  }
}
