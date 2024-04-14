import 'dart:typed_data';

import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/address_service.dart';

class LegacyAddressArgs {
  final Uint8List publicKeyIntList;
  String network;
  LegacyAddressArgs({required this.publicKeyIntList, required this.network});
}

class LegacyAddress extends AddressService {
  @override
  String deriveAddress(dynamic args) {
    LegacyAddressArgs typedArgs = args as LegacyAddressArgs;
    return btcAddress(typedArgs.publicKeyIntList, _getVersion(typedArgs.network));
  }

  _getVersion(String network) {
    if (network == 'testnet') {
      return 0x6F; // testnet version
    }
    return 0x00;
  }
}
