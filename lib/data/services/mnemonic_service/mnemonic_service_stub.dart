// data/services/mnemonic_service_stub.dart

import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/bip39.dart';

class MnemonicServiceStub implements MnemonicService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  String generateMnemonic() => _unsupported('generateMnemonic');

  @override
  bool validateMnemonic(String mnemonic) => _unsupported('validateMnemonic');

  @override
  String mnemonicToEntropy(String mnemonic) =>
      _unsupported('mnemonicToEntropy');

  @override
  bool validateCounterwalletMnemonic(String mnemonic) =>
      _unsupported('validateCounterwalletMnemonic');
}

MnemonicService createMnemonicServiceImpl({
  required Bip39Service bip39Service,
}) =>
    MnemonicServiceStub();
