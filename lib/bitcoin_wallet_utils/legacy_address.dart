import 'dart:typed_data';

import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';

class LegacyAddress {
  String createAddress(Uint8List publicKeyIntList, String network) {
    return btcAddress(publicKeyIntList, _getVersion(network));
  }

  _getVersion(String network) {
    if (network == 'testnet') {
      return 0x6F; // testnet version
    }
    return 0x00;
  }
}
