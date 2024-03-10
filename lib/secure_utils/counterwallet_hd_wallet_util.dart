import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:hex/hex.dart';

class CounterwalletHDWalletUtil {
  final bip39 = Bip39();
  final basePath = 'm/0\'/0/';

  Address createBip32AddressFromSeed(String mnemonic, int index) {
    Uint8List seed = bip39.mnemonicToSeed(mnemonic);
    NetworkType network = _getNetwork();
    final nodeFromSeed = BIP32.fromSeed(seed, network);
    final addressKey = nodeFromSeed.derivePath(basePath + index.toString());

    final privateKey = addressKey.toWIF();
    final publicKey = addressKey.publicKey;

    // final address = nodeFromSeed.address;
    final address = btcAddress(addressKey.publicKey, _getVersion());
    return Address(
        address: address,
        publicKey: HEX.encode(publicKey),
        privateKey: privateKey);
  }

  _getNetwork() {
    if (dotenv.env['ENV'] == 'testnet') {
      // wif hex source:  https://learnmeabitcoin.com/technical/keys/private-key/wif/
      return NetworkType(
          wif: 0xef,
          bip32: Bip32Type(
              public: 0x043587CF, private: 0x04358394)); // testnet version
    }
    return NetworkType(
        wif: 0x80,
        bip32: Bip32Type(
            public: 0x0488b21e, private: 0x0488ade4)); // mainnet version
  }

  _getVersion() {
    if (dotenv.env['ENV'] == 'testnet') {
      // wif hex source:  https://learnmeabitcoin.com/technical/keys/private-key/wif/
      return 0x6F; // testnet version
    }
    return 0x00;
  }
}
