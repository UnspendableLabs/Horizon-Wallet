import 'dart:typed_data';

import 'package:flutter_hd_wallet/flutter_hd_wallet.dart';
import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/pub_priv_key_service.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/key_pair.dart';

class Bip32KeyPairArgs {
  final Uint8List seedIntList;
  final NetworkEnum network;
  final String path;
  Bip32KeyPairArgs({required this.seedIntList, required this.network, required this.path});
}

class Bip32KeyPairService extends PublicPrivateKeyService {
  @override
  KeyPair createPublicPrivateKeyPairForPath(dynamic args) {
    Bip32KeyPairArgs typedArgs = args as Bip32KeyPairArgs;
    NetworkType networkType = _getNetwork(typedArgs.network);
    final nodeFromSeed = BIP32.fromSeed(typedArgs.seedIntList, networkType);
    BIP32 addressKey = nodeFromSeed.derivePath(typedArgs.path);

    return KeyPair(publicKeyIntList: addressKey.publicKey, privateKey: addressKey.toWIF());
  }

  _getNetwork(NetworkEnum network) {
    switch (network) {
      case (NetworkEnum.testnet):
        // wif hex source:  https://learnmeabitcoin.com/technical/keys/private-key/wif/
        return NetworkType(wif: 0xef, bip32: Bip32Type(public: 0x043587CF, private: 0x04358394)); // testnet
      case (NetworkEnum.mainnet):
        return NetworkType(wif: 0x80, bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4)); // mainnet
    }
  }
}
