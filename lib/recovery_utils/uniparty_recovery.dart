import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bech32.dart';
import 'package:counterparty_wallet/secure_utils/bip44.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnipartyRecovery {
  final bip44 = Bip44();
  final bech32 = Bech32Address();

  List<WalletInfo> recoverUniparty(String mnemonic) {
    List<WalletInfo> wallets = [];

    BasePath path = BasePath(coinType: _getCoinType(), account: 0, change: 0, index: 0);
    KeyPair keyPair = bip44.createBip44KeyPairFromSeed(mnemonic, path);
    String address = bech32.deriveBech32Address(keyPair.publicKey);
    WalletInfo wallet = WalletInfo(address: address, publicKey: hex.encode(keyPair.publicKey), privateKey: keyPair.privateKey);

    wallets.add(wallet);
    return wallets;
  }

  int _getCoinType() {
    if (dotenv.env['ENV'] == 'testnet') {
      return 1; // testnet
    }
    return 0; // mainnet
  }
}
