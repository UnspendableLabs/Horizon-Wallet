import 'dart:typed_data';
import 'dart:developer';
import 'package:get_it/get_it.dart';

import 'package:convert/convert.dart';
import 'package:dartsv/dartsv.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_address.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/bech32.dart';
import 'package:uniparty/bitcoin_wallet_utils/bech32_address.dart'
    as bech32_utils;

Bech32Service bech32 = GetIt.I.get<Bech32Service>();

List<WalletNode> createWallet(
    NetworkEnum network, String seedHex, WalletTypeEnum walletType) {
  int numAddresses = _numAddresses(walletType);
  List<WalletNode> walletNodes = [];

  switch (walletType) {
    case WalletTypeEnum.bip44:
      String basePath = 'm/44\'/${_getCoinType(network)}\'/0\'/0/';

      for (var i = 0; i < numAddresses; i++) {
        debugger(when: true);

        HDPrivateKey seededKey = deriveSeededKey(seedHex, network);

        String path = basePath + i.toString();

        HDPrivateKey derivedKey = deriveChildKey(seededKey, path);

        derivedKey.networkType = getNetworkType(network);
        SVPrivateKey xpriv = derivedKey.privateKey;
        HDPublicKey xPub = derivedKey.hdPublicKey;
        SVPublicKey svpubKey = xPub.publicKey;

        String publicKey = svpubKey.toHex();
        String privateKey = xpriv.toWIF();

        String prefix = bech32_utils.bech32PrefixForNetwork(network);
        Uint8List words = bech32_utils
            .publicKeyToWords(Uint8List.fromList(hex.decode(publicKey)));

        List<int> words2 = bech32.toWords(hex.decode(publicKey));

        print("words");
        print(words);
        print("words 2");
        print(words2);

        String address = bech32.encode(prefix, words);

        WalletNode walletNode = WalletNode(
            address: address,
            publicKey: publicKey,
            privateKey: privateKey,
            index: i);

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

        WalletNode walletNodeNormal = WalletNode(
            address: legacyAddress,
            publicKey: publicKey,
            privateKey: privateKey,
            index: i);

        walletNodes.add(walletNodeNormal);

        String prefix = bech32_utils.bech32PrefixForNetwork(network);
        Uint8List words = bech32_utils
            .publicKeyToWords(Uint8List.fromList(hex.decode(publicKey)));
        String address = bech32.encode(prefix, words);

        WalletNode walletNodeBech32 = WalletNode(
            address: address,
            publicKey: publicKey,
            privateKey: privateKey,
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

int _numAddresses(WalletTypeEnum walletType) =>
    walletType == WalletTypeEnum.bip44 ? 1 : 10;
