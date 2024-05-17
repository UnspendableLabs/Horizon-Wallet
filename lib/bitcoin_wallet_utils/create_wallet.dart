import 'dart:typed_data';
import 'dart:developer';
import 'package:get_it/get_it.dart';

import 'dart:js_interop';
import 'package:convert/convert.dart';
import 'package:dartsv/dartsv.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_address.dart';
import 'package:uniparty/common/constants.dart' as c;
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/models/seed.dart';
import 'package:uniparty/services/bech32.dart';
import 'package:uniparty/services/bip32.dart' as bip32;
import 'package:uniparty/js/bip32.dart' as bip32js;
import 'package:uniparty/services/ecpair.dart' as ecpair;
import 'package:uniparty/js/common.dart' as common;
import 'package:uniparty/bitcoin_wallet_utils/bech32_address.dart'
    as bech32_utils;

Bech32Service bech32 = GetIt.I.get<Bech32Service>();
bip32.Bip32Service bip32Service = GetIt.I.get<bip32.Bip32Service>();
ecpair.ECPairService ecpairService = GetIt.I.get<ecpair.ECPairService>();

List<WalletNode> createWallet(
    c.NetworkEnum network, String seedHex, c.WalletType walletType) {
  int numAddresses = _numAddresses(walletType);
  List<WalletNode> walletNodes = [];

  switch (walletType) {
    case c.WalletType.uniparty:
      Seed seed = Seed.fromHex(seedHex);

      common.Network _network = network == c.NetworkEnum.testnet
          ? ecpairService.testnet
          : ecpairService.mainnet;

      debugger(when: true);
      bip32js.BIP32Interface root = bip32Service.fromSeed(seed.bytes, _network);

      String path = 'm/84\'/${_getCoinType(network)}\'/0\'/0/0';

      bip32js.BIP32Interface child = root.derivePath(path);

      String prefix = bech32_utils.bech32PrefixForNetwork(network);

      // TODO: remove type cast
      List<int> words =
          bech32.toWords(Uint8List.fromList(child.publicKey.toDart));

      String address = bech32.encode(prefix, words);

      WalletNode walletNode = WalletNode(
          address: address,
          publicKey: hex.encode(child.publicKey.toDart),
          privateKey: child.toWIF(),
          index: 0);

      walletNodes.add(walletNode);

      // String basePath = 'm/48\'/${_getCoinType(network)}\'/0\'/0/';
      //
      // for (var i = 0; i < numAddresses; i++) {
      //   debugger(when: true);
      //
      //   HDPrivateKey seededKey = deriveSeededKey(seedHex, network);
      //
      //   String path = basePath + i.toString();
      //
      //   HDPrivateKey derivedKey = deriveChildKey(seededKey, path);
      //
      //   derivedKey.networkType = getNetworkType(network);
      //   SVPrivateKey xpriv = derivedKey.privateKey;
      //   HDPublicKey xPub = derivedKey.hdPublicKey;
      //   SVPublicKey svpubKey = xPub.publicKey;
      //
      //   String publicKey = svpubKey.toHex();
      //   String privateKey = xpriv.toWIF();
      //
      //   String prefix = bech32_utils.bech32PrefixForNetwork(network);
      //   Uint8List words = bech32_utils
      //       .publicKeyToWords(Uint8List.fromList(hex.decode(publicKey)));
      //
      //   List<int> words2 = bech32.toWords(hex.decode(publicKey));
      //
      //   print("words");
      //   print(words);
      //   print("words 2");
      //   print(words2);
      //
      //   String address = bech32.encode(prefix, words);
      //
      //   WalletNode walletNode = WalletNode(
      //       address: address,
      //       publicKey: publicKey,
      //       privateKey: privateKey,
      //       index: i);
      //
      //   walletNodes.add(walletNode);
      // }
      break;

    case c.WalletType.counterwallet:
      throw UnsupportedError('wallet type $walletType not supported');
    case c.WalletType.freewallet:
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

int _getCoinType(c.NetworkEnum network) {
  switch (network) {
    case c.NetworkEnum.testnet:
      return 1; // testnet
    case c.NetworkEnum.mainnet:
      return 0; // mainnet
  }
}

int _numAddresses(c.WalletType walletType) => 1;



    // walletType == WalletTypeEnum.bip44 ? 1 : 10;
