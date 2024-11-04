import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/js/mnemonicjs.dart';
import 'dart:js_interop';

class MnemonicServiceImpl implements MnemonicService {
  Bip39Service bip39Service;
  MnemonicServiceImpl(this.bip39Service);

  @override
  String generateMnemonic() {
    return bip39Service.generateMnemonic();
  }

  @override
  bool validateMnemonic(String mnemonic) {
    return bip39Service.validateMnemonic(mnemonic);
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    return bip39Service.mnemonicToEntropy(mnemonic);
  }

  @override // Add a method to validate Counterwallet mnemonics
  bool validateCounterwalletMnemonic(String mnemonic) {
    final words = mnemonic.split(' ');
    if (words.length != 12) return false;

    // Get the valid words list from the Mnemonic class
    final validWords = Mnemonic.words.toDart.cast<String>();

    // Check if all words exist in the wordlist
    return words.every((word) => validWords.contains(word));
  }
}
