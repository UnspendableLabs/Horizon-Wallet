import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/address_service.dart';
import 'package:uniparty/models/base_path.dart';

class Bip44AddressArgs {
  final BIP44 node;
  final BasePath path;
  Bip44AddressArgs({required this.node, required this.path});
}

class Bip44Address extends AddressService {
  @override
  @override
  String deriveAddress(dynamic args) {
    Bip44AddressArgs typedArgs = args as Bip44AddressArgs;

    String address =
        typedArgs.node.address(account: typedArgs.path.account, change: typedArgs.path.change, index: typedArgs.path.index);
    return address;
  }
}
