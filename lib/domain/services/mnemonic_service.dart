abstract class MnemonicService {
  String generateMnemonic();
  bool validateMnemonic(String mnemonic);
  String mnemonicToEntropy(String mnemonic);
  bool validateCounterwalletMnemonic(String mnemonic);
}
