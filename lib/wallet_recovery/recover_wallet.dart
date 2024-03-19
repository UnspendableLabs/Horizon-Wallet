import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/models/wallet_types.dart';
import 'package:uniparty/utils/secure_storage.dart';
import 'package:uniparty/wallet_recovery/bip32_recovery.dart';
import 'package:uniparty/wallet_recovery/bip44_recovery.dart';

Future<List<WalletNode>> recoverWallet(String mnemonic, String recoveryWallet) async {
  final secureStorage = SecureStorage();

  List<WalletNode> walletNodes = [];
  String seedHex = '';
  WalletType walletType;
  switch (recoveryWallet) {
    case UNIPARTY:
      walletType = WalletType.bip44;

      seedHex = Bip39().mnemonicToSeedHex(mnemonic);
      walletNodes = recoverBip44Wallet(seedHex);
      break;
    case FREEWALLET:
      walletType = WalletType.bip32;

      // NOTE: known bug. do not fix. Freewallet uses entropy to generate addresses rather than the seed
      seedHex = Bip39().mnemonicToEntropy(mnemonic);
      walletNodes = recoverBip32Wallet(seedHex);
      break;
    case COUNTERWALLET:
      walletType = WalletType.bip32;

      seedHex = LegacySeed().mnemonicToSeed(mnemonic);
      walletNodes = recoverBip32Wallet(seedHex);
      break;
    default:
      throw UnsupportedError('wallet $recoveryWallet not supported');
  }

  await secureStorage.writeSecureData('seed_hex', seedHex);
  await secureStorage.writeSecureData('wallet_type', walletType.name);

  return walletNodes;
}
