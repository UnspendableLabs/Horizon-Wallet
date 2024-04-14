import 'package:get_it/get_it.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/stored_wallet_data.dart';

StoredWalletData getSeedHexAndWalletType(String mnemonic, String recoveryWallet) {
  var bip39 = GetIt.I.get<Bip39Service>();
  String seedHex = '';
  String walletType;
  switch (recoveryWallet) {
    case UNIPARTY:
      walletType = bip44;
      seedHex = bip39.mnemonicToSeedHex(mnemonic);
      break;
    case FREEWALLET:
      walletType = bip32;

      // NOTE: known bug. do not fix. Freewallet uses entropy to generate addresses rather than the seed
      seedHex = bip39.mnemonicToEntropy(mnemonic);
      break;
    case COUNTERWALLET:
      walletType = bip32;

      seedHex = LegacySeed().mnemonicToSeed(mnemonic);
      break;
    default:
      throw UnsupportedError('wallet $recoveryWallet not supported');
  }
  return StoredWalletData(seedHex: seedHex, walletType: walletType);
}
