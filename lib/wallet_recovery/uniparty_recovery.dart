import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bech32.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/bip44.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnipartyRecovery {
  final bip44 = Bip44();
  final bip39 = Bip39();
  final bech32 = Bech32Address();

  List<WalletNode> recoverUniparty(String mnemonic) {
    String seedHex = bip39.mnemonicToSeedHex(mnemonic);

    List<WalletNode> nodes = [];

    BasePath path = BasePath(coinType: _getCoinType(), account: 0, change: 0, index: 0);
    KeyPair keyPair = bip44.createBip44KeyPairFromSeed(seedHex, path);
    String address = bech32.deriveBech32Address(keyPair.publicKeyIntList);
    WalletNode walletNode = WalletNode(
        address: address,
        publicKey: hex.encode(keyPair.publicKeyIntList),
        privateKey: keyPair.privateKey);

    nodes.add(walletNode);
    return nodes;
  }

  int _getCoinType() {
    if (dotenv.env['ENV'] == 'testnet') {
      return 1; // testnet
    }
    return 0; // mainnet
  }
}
