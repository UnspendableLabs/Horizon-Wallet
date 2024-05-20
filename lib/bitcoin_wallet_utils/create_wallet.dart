import 'dart:js_interop';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart' as c;
import 'package:uniparty/js/bip32.dart' as bip32js;
import 'package:uniparty/js/common.dart' as common;
import 'package:uniparty/models/seed.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/bech32.dart';
import 'package:uniparty/services/bip32.dart' as bip32;
import 'package:uniparty/services/ecpair.dart' as ecpair;

Bech32Service bech32 = GetIt.I.get<Bech32Service>();
bip32.Bip32Service bip32Service = GetIt.I.get<bip32.Bip32Service>();
ecpair.ECPairService ecpairService = GetIt.I.get<ecpair.ECPairService>();

List<WalletNode> createWallet(c.NetworkEnum network, String seedHex, c.WalletType walletType) {
  int numAddresses = _numAddresses(walletType);
  List<WalletNode> walletNodes = [];

  final Seed seed = Seed.fromHex(seedHex);

  // final stopwatch = Stopwatch()..start();

  switch (walletType) {
    case c.WalletType.uniparty:
      common.Network _network = network == c.NetworkEnum.testnet ? ecpairService.testnet : ecpairService.mainnet;

      _network.bip32.private = 0x4b2430c; //zpriv
      _network.bip32.public = 0x4b24746; //zpub

      final bip32js.BIP32Interface root = bip32Service.fromSeed(seed.bytes, _network);

      final bip32js.BIP32Interface extended = root.derivePath('m/84\'/${_getCoinType(network)}\'/0\'/0');

      final bip32js.BIP32Interface child = extended.derive(0);

      // TODO: remove type cast
      List<int> words = bech32.toWords(Uint8List.fromList(child.identifier.toDart));
      // need to add 0 version byte
      words.insert(0, 0);

      final String address = bech32.encode(_network.bech32, words);

      WalletNode walletNode =
          WalletNode(address: address, publicKey: hex.encode(child.publicKey.toDart), privateKey: child.toWIF(), index: 0);
      walletNodes.add(walletNode);
      break;

    case c.WalletType.counterwallet:
      throw UnsupportedError('wallet type $walletType not supported');
    case c.WalletType.freewallet:
      common.Network _network = network == c.NetworkEnum.testnet ? ecpairService.testnet : ecpairService.mainnet;

      _network.bip32.private = 0x4b2430c; //zpriv
      _network.bip32.public = 0x4b24746; //zpub

      throw UnsupportedError('wallet type $walletType not supported');

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


