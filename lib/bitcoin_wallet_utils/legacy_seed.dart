import 'package:uniparty/bitcoin_wallet_utils/legacy_mnemonic_js.dart';

class LegacySeed {
  final mnemonicJs = MnemonicJs();

  String mnemonicToSeed(String mnemonic) {
    return mnemonicJs.wordsToSeed(mnemonic);
  }
}
