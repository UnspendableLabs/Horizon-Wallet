import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/address_service.dart';
import 'package:uniparty/common/constants.dart';

class LegacyAddress extends AddressService {
  @override
  String deriveAddress(AddressArgs args) {
    return btcAddress(args.publicKeyIntList, _getVersion(args.network));
  }

  _getVersion(NetworkEnum network) {
    switch (network) {
      case NetworkEnum.testnet:
        return 0x6F;
      case NetworkEnum.mainnet:
        return 0x00;
    }
  }
}
