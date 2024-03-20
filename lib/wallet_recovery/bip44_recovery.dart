import 'package:convert/convert.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uniparty/bitcoin_wallet_utils/bech32.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip44.dart';
import 'package:uniparty/models/base_path.dart';
import 'package:uniparty/models/key_pair.dart';
import 'package:uniparty/models/wallet_node.dart';

List<WalletNode> recoverBip44Wallet(String seedHex) {
  final bip44 = Bip44();
  final bech32 = Bech32Address();

  List<WalletNode> nodes = [];

  BasePath path = BasePath(coinType: _getCoinType(), account: 0, change: 0, index: 0);
  KeyPair keyPair = bip44.createBip44KeyPairFromSeed(seedHex, path);
  String address = bech32.deriveBech32Address(keyPair.publicKeyIntList);
  WalletNode walletNode = WalletNode(
      address: address,
      publicKey: hex.encode(keyPair.publicKeyIntList),
      privateKey: keyPair.privateKey,
      index: path.index);

  nodes.add(walletNode);
  return nodes;
}

int _getCoinType() {
  if (dotenv.env['ENV'] == 'testnet') {
    return 1; // testnet
  }
  return 0; // mainnet
}
