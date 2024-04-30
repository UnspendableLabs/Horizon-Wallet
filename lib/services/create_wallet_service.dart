import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dartsv/dartsv.dart';
import 'package:uniparty/bitcoin_wallet_utils/bech32_address.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_address.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';

class CreateWalletService {
  List<WalletNode> createWallet(NetworkEnum network, String seedHex, WalletTypeEnum walletType) {
    int numAddresses = _numAddresses(walletType);
    List<WalletNode> walletNodes = [];

    switch (walletType) {
      case WalletTypeEnum.bip44:
        String basePath = 'm/44\'/${_getCoinType(network)}\'/0\'/0/';

        for (var i = 0; i < numAddresses; i++) {
          HDPrivateKey seededKey = deriveSeededKey(seedHex, network);

          String path = basePath + i.toString();

          HDPrivateKey derivedKey = deriveChildKey(seededKey, path);

          derivedKey.networkType = getNetworkType(network);
          SVPrivateKey xpriv = derivedKey.privateKey;
          HDPublicKey xPub = derivedKey.hdPublicKey;
          SVPublicKey svpubKey = xPub.publicKey;

          String publicKey = svpubKey.toHex();
          String privateKey = xpriv.toWIF();

          String address = deriveBech32Address(Uint8List.fromList(hex.decode(publicKey)), network);

          WalletNode walletNode = WalletNode(address: address, publicKey: publicKey, privateKey: privateKey, index: i);

          walletNodes.add(walletNode);
        }
        break;
      case WalletTypeEnum.bip32:
        String basePath = 'm/0\'/0/';

        for (var i = 0; i < numAddresses; i++) {
          HDPrivateKey seededKey = deriveSeededKey(seedHex, network);

          String path = basePath + i.toString();

          HDPrivateKey derivedKey = deriveChildKey(seededKey, path);

          derivedKey.networkType = getNetworkType(network);
          SVPrivateKey xpriv = derivedKey.privateKey;
          HDPublicKey xPub = derivedKey.hdPublicKey;
          SVPublicKey svpubKey = xPub.publicKey;
          String publicKey = svpubKey.toHex();
          String privateKey = xpriv.toWIF();

          // Freewallet derives 10 legacy and 10 bech32 addresses on initialization.
          String legacyAddress = deriveLegacyAddress(svpubKey, network);

          WalletNode walletNodeNormal =
              WalletNode(address: legacyAddress, publicKey: publicKey, privateKey: privateKey, index: i);

          walletNodes.add(walletNodeNormal);

          String bech32Address = deriveBech32Address(Uint8List.fromList(hex.decode(publicKey)), network);

          WalletNode walletNodeBech32 =
              WalletNode(address: bech32Address, publicKey: publicKey, privateKey: privateKey, index: i);

          walletNodes.add(walletNodeBech32);
        }
        break;
      default:
        throw UnsupportedError('wallet type $walletType not supported');
    }

    return walletNodes;
  }

  int _getCoinType(NetworkEnum network) {
    switch (network) {
      case NetworkEnum.testnet:
        return 1; // testnet
      case NetworkEnum.mainnet:
        return 0; // mainnet
    }
  }

  int _numAddresses(WalletTypeEnum walletType) => walletType == WalletTypeEnum.bip44 ? 1 : 10;
}
