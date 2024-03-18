import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';

class Bip32 {
  final basePath = 'm/0\'/0/';

  KeyPair createBip32PubKeyPrivateKeyFromSeed(Uint8List seedIntList, int index) {
    NetworkType network = _getNetwork();
    final nodeFromSeed = BIP32.fromSeed(seedIntList, network);
    BIP32 addressKey = nodeFromSeed.derivePath(basePath + index.toString());

    return KeyPair(publicKeyIntList: addressKey.publicKey, privateKey: addressKey.toWIF());
  }

  _getNetwork() {
    if (dotenv.env['ENV'] == 'testnet') {
      // wif hex source:  https://learnmeabitcoin.com/technical/keys/private-key/wif/
      return NetworkType(
          wif: 0xef, bip32: Bip32Type(public: 0x043587CF, private: 0x04358394)); // testnet version
    }
    return NetworkType(
        wif: 0x80, bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4)); // mainnet version
  }
}
