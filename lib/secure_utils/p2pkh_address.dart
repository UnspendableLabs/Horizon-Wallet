import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';

class P2PKHAddress {
  String createAddress(Uint8List publicKey) {
    return btcAddress(publicKey, _getVersion());
  }

  _getVersion() {
    if (dotenv.env['ENV'] == 'testnet') {
      return 0x6F; // testnet version
    }
    return 0x00;
  }
}
