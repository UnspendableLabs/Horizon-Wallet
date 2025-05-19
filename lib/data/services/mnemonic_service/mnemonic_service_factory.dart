// data/services/mnemonic_service_factory.dart

import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/bip39.dart';

import 'mnemonic_service_stub.dart'
    if (dart.library.io) 'mnemonic_service_native.dart'
    if (dart.library.html) 'mnemonic_service_web.dart';

MnemonicService createMnemonicService({
  required Bip39Service bip39Service,
}) =>
    createMnemonicServiceImpl(bip39Service: bip39Service);
