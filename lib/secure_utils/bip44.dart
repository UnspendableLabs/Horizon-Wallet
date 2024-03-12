import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:dart_wif/dart_wif.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';

class Bip44 {
  Address createBip44AddressFromSeed(String seed, BasePath path) {
    final node = BIP44.fromSeed(seed, coinType: path.coinType);

    final privateKeyHex = node.privateKeyHex(
        account: path.account, change: path.change, index: path.index);

    final publicKey = node.publicKeyHex(
        account: path.account, change: path.change, index: path.index);

    final address = node.address(
        account: path.account, change: path.change, index: path.index);

    Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));

    final WIF decoded =
        WIF(version: _getVersion(), privateKey: privateKey, compressed: true);

    String key =
        wif.encode(decoded); // for the testnet use: Wif.encode(239, ...

    return Address(
      address: address,
      publicKey: publicKey,
      privateKey: key,
    );
  }

  int _getVersion() {
    if (dotenv.env['ENV'] == 'testnet') {
      return 239;
    }
    return 128; // mainnet version
  }
}
