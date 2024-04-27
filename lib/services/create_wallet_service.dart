import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/address_service.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/bech32_address.dart';
import 'package:uniparty/bitcoin_wallet_utils/address_utils/legacy_address.dart';
import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/bip32_key_pair.dart';
import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/bip44_key_pair.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/base_path.dart';
import 'package:uniparty/models/key_pair.dart';
import 'package:uniparty/models/wallet_node.dart';

class CreateWalletService {
  final bip44 = Bip44KeyPairService();
  final bech32 = Bech32Address();
  final bip32 = Bip32KeyPairService();
  final legacyAddress = LegacyAddress();

  Future<List<WalletNode>> createWallet(NetworkEnum network, String seedHex, WalletTypeEnum walletType) async {
    int numAddresses = _numAddresses(walletType);
    List<WalletNode> walletNodes = [];

    switch (walletType) {
      case WalletTypeEnum.bip44:
        for (var i = 0; i < numAddresses; i++) {
          BasePath path = BasePath(coinType: _getCoinType(network), account: 0, change: 0, index: i);

          KeyPair keyPair =
              bip44.createPublicPrivateKeyPairForPath(Bip44KeyPairArgs(seedHex: seedHex, path: path, network: network));

          String address = bech32.deriveAddress(AddressArgs(publicKeyIntList: keyPair.publicKeyIntList, network: network));

          WalletNode walletNode = WalletNode(
              address: address,
              publicKey: hex.encode(keyPair.publicKeyIntList),
              privateKey: keyPair.privateKey,
              index: path.index);

          walletNodes.add(walletNode);
        }
        break;
      case WalletTypeEnum.bip32:
        String basePath = 'm/0\'/0/';

        for (var i = 0; i < numAddresses; i++) {
          String path = basePath + i.toString();
          KeyPair keyPair = bip32.createPublicPrivateKeyPairForPath(
              Bip32KeyPairArgs(seedIntList: Uint8List.fromList(hex.decode(seedHex)), path: path, network: network));

          // Freewallet derives 10 legacy and 10 bech32 addresses on initialization.
          // This does the same; maybe we dont want to derive all 20?
          String normalAddress =
              legacyAddress.deriveAddress(AddressArgs(publicKeyIntList: keyPair.publicKeyIntList, network: network));

          WalletNode walletNodeNormal = WalletNode(
              address: normalAddress,
              publicKey: hex.encode(keyPair.publicKeyIntList),
              privateKey: keyPair.privateKey,
              index: i);

          walletNodes.add(walletNodeNormal);

          String bech32Address =
              bech32.deriveAddress(AddressArgs(publicKeyIntList: keyPair.publicKeyIntList, network: network));

          WalletNode walletNodeBech32 = WalletNode(
              address: bech32Address,
              publicKey: hex.encode(keyPair.publicKeyIntList),
              privateKey: keyPair.privateKey,
              index: i);

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
