import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';

WalletRetrieveInfo getSeedHexAndWalletType(String mnemonic, String recoveryWallet) {
  String seedHex = '';
  String walletType;
  switch (recoveryWallet) {
    case UNIPARTY:
      walletType = bip44;

      seedHex = Bip39().mnemonicToSeedHex(mnemonic);
      break;
    case FREEWALLET:
      walletType = bip32;

      // NOTE: known bug. do not fix. Freewallet uses entropy to generate addresses rather than the seed
      seedHex = Bip39().mnemonicToEntropy(mnemonic);
      break;
    case COUNTERWALLET:
      walletType = bip32;

      seedHex = LegacySeed().mnemonicToSeed(mnemonic);
      break;
    default:
      throw UnsupportedError('wallet $recoveryWallet not supported');
  }
  return WalletRetrieveInfo(seedHex: seedHex, walletType: walletType);

  // await secureStorage.writeSecureData('seed_hex', seedHex);
  // await secureStorage.writeSecureData('wallet_type', walletType);
}
