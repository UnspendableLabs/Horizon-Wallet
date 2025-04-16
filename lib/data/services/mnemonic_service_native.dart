import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/bip39.dart';

class MnemonicServiceNative implements MnemonicService {
  Bip39Service bip39Service;
  MnemonicServiceNative(this.bip39Service);

  @override
  String generateMnemonic() {
    throw UnimplementedError();
  }

  @override
  bool validateMnemonic(String mnemonic) {
    throw UnimplementedError();
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    throw UnimplementedError();
  }

  @override // Add a method to validate Counterwallet mnemonics
  bool validateCounterwalletMnemonic(String mnemonic) {
    throw UnimplementedError();
  }
}
