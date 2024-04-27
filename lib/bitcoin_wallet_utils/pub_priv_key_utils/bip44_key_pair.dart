import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_wif/dart_wif.dart';
import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/pub_priv_key_service.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/base_path.dart';
import 'package:uniparty/models/key_pair.dart';

class Bip44KeyPairArgs {
  final String seedHex;
  final BasePath path;
  final NetworkEnum network;
  Bip44KeyPairArgs({required this.seedHex, required this.path, required this.network});
}

class Bip44KeyPairService extends PublicPrivateKeyService {
  @override
  KeyPair createPublicPrivateKeyPairForPath(dynamic args) {
    Bip44KeyPairArgs typedArgs = args as Bip44KeyPairArgs;
    BIP44 node = BIP44.fromSeed(typedArgs.seedHex, coinType: typedArgs.path.coinType);
    final privateKeyHex =
        node.privateKeyHex(account: typedArgs.path.account, change: typedArgs.path.change, index: typedArgs.path.index);

    String publicKey =
        node.publicKeyHex(account: typedArgs.path.account, change: typedArgs.path.change, index: typedArgs.path.index);

    Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));

    final WIF decoded = WIF(version: _getVersion(typedArgs.network), privateKey: privateKey, compressed: true);

    String privateKeyWif = wif.encode(decoded);

    return KeyPair(publicKeyIntList: Uint8List.fromList(hex.decode(publicKey)), privateKey: privateKeyWif);
  }

  int _getVersion(NetworkEnum network) {
    switch (network) {
      case NetworkEnum.testnet:
        return 239;
      case NetworkEnum.mainnet:
        return 128;
    }
  }
}
