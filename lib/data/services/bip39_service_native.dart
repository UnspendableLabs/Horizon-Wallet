import 'package:horizon/data/models/seed.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

class Bip39ServiceNative implements Bip39Service {
  @override
  String generateMnemonic() {
    Mnemonic mnemonic =
        Bip39MnemonicGenerator().fromWordsNumber(Bip39WordsNum.wordsNum12);

    return mnemonic.toString();
  }

  @override
  Future<Seed> mnemonicToSeed(String mnemonicStr) async {
    throw UnimplementedError("BIP39ServiceNative.mnemonicToSeed()");
  }

  @override
  Seed mnemonicToSeedSync(String mnemonic) {
    throw UnimplementedError("BIP39ServiceNative.mnemonicToSeedSync()");
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    throw UnimplementedError("BIP39ServiceNative.mnemonicToEntropy()");
  }

  @override
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]) {
    final validator = Bip39MnemonicValidator();

    return validator.validateWords(mnemonic);
  }
}
