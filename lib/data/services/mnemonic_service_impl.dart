import 'package:uniparty/domain/services/mnemonic_service.dart';
import 'package:uniparty/services/bip39.dart';


class MnemonicServiceImpl implements MnemonicService {

  Bip39Service bip39Service;
  MnemonicServiceImpl(this.bip39Service);

  @override
  String generateMnemonic() {
    return bip39Service.generateMnemonic();
  }

}
