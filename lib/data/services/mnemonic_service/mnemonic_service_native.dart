import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/bip39.dart';

class MnemonicServiceNative implements MnemonicService {
  final Bip39Service bip39Service;

  MnemonicServiceNative(this.bip39Service);

  @override
  String generateMnemonic() {
    throw UnimplementedError(
      '[MnemonicServiceNative] generateMnemonic() is not implemented for native platform.',
    );
  }

  @override
  bool validateMnemonic(String mnemonic) {
    return bip39Service.validateMnemonic(mnemonic);
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    throw UnimplementedError(
      '[MnemonicServiceNative] mnemonicToEntropy() is not implemented for native platform.',
    );
  }

  @override
  bool validateCounterwalletMnemonic(String mnemonic) {
    throw UnimplementedError(
      '[MnemonicServiceNative] validateCounterwalletMnemonic() is not implemented for native platform.',
    );
  }
}

MnemonicService createMnemonicServiceImpl({
  required Bip39Service bip39Service,
}) =>
    MnemonicServiceNative(bip39Service);
