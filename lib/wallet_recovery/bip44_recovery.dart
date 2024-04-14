// import 'package:convert/convert.dart';
// import 'package:uniparty/bitcoin_wallet_utils/address_utils/bech32_address.dart';
// import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/bip44_key_pair.dart';
// import 'package:uniparty/models/base_path.dart';
// import 'package:uniparty/models/key_pair.dart';
// import 'package:uniparty/models/wallet_node.dart';

// List<WalletNode> recoverBip44Wallet(String seedHex, String network) {
//   final bip44 = Bip44();
//   final bech32 = Bech32Address();

//   List<WalletNode> nodes = [];

//   BasePath path = BasePath(coinType: _getCoinType(network), account: 0, change: 0, index: 0);
//   KeyPair keyPair = bip44.createBip44KeyPairFromSeed(seedHex, path, network);
//   String address = bech32.deriveBech32Address(keyPair.publicKeyIntList, network);
//   WalletNode walletNode = WalletNode(
//       address: address, publicKey: hex.encode(keyPair.publicKeyIntList), privateKey: keyPair.privateKey, index: path.index);

//   nodes.add(walletNode);
//   return nodes;
// }

// int _getCoinType(String network) {
//   if (network == 'testnet') {
//     return 1; // testnet
//   }
//   return 0; // mainnet
// }
