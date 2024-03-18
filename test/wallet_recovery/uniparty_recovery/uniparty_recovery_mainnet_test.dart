import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';
import 'package:uniparty/secure_utils/models/wallet_info.dart';
import 'package:uniparty/wallet_recovery/uniparty_recovery.dart';

void main() async {
  await dotenv.load();

  // A Bech32 address encoded (p2wpkh): HRP + Separator + Data values verified from https://secretscan.org/Bech32
  group('Test recover uniparty walletNode mainnet', () {
    final unipartyRecovery = UnipartyRecovery();

    test('recoverUniparty1', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';

      List<WalletNode> walletNodes = unipartyRecovery.recoverUniparty(mnemonic);

      WalletNode walletNode = walletNodes[0];

      expect(walletNode.address, 'bc1qdmfxhnh0v2p79guqvcav8ecc8rzyhrfked5fkt');
      expect(walletNode.publicKey,
          '02ff5e001258801f2a32ceb4702a4e0b2c8f68d2a4afc85a01d17a568b720ef12a');
      expect(walletNode.privateKey, 'KxFniLGmDo8VMPFHXgB1tokQArFgXQtJKkUATWWqTMYL2TAg9EDt');
    });

    test('recoverUniparty2', () {
      String mnemonic =
          'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';

      List<WalletNode> walletNodes = unipartyRecovery.recoverUniparty(mnemonic);

      WalletNode walletNode = walletNodes[0];

      expect(walletNode.address, 'bc1qkxce32pm8mcy7xewk3kw0mw5sca3ryq5w8rkk6');
      expect(walletNode.publicKey,
          '0206f76460bc5e08bde63c521e8cb10606d5e6177462136ee7d973326f1acee7f0');
      expect(walletNode.privateKey, 'KychZjnRqKdFVsUYTojAZZ7HYjdKdwXF3a9RkHPfVYCSRJKR9P3s');
    });

    test('recoverUniparty3', () {
      String mnemonic =
          'thunder member interest display shock unable clarify fiber insect lumber battle off';

      List<WalletNode> walletNodes = unipartyRecovery.recoverUniparty(mnemonic);

      WalletNode walletNode = walletNodes[0];

      expect(walletNode.address, 'bc1qnrh9rj5twj9zvjfx69jpvz8lhelmfrsdlen6jr');
      expect(walletNode.publicKey,
          '02cc363e4f4e1a872ee548c48e4f31c333c649b0a9740870708ec7666ff651ae16');
      expect(walletNode.privateKey, 'L1rsQJ3nCvgkphf7HShV9bZD2kY5EQNM2Udp66RTUzccbtTDXiEG');
    });

    test('recoverUniparty4', () {
      String mnemonic =
          'crime speak truly valid movie describe blame essay crack skirt december obey';

      List<WalletNode> walletNodes = unipartyRecovery.recoverUniparty(mnemonic);

      WalletNode walletNode = walletNodes[0];

      expect(walletNode.address, 'bc1qc3ffwuye6m0lddfuxur2rc49c4scdkyj9x3gc6');
      expect(walletNode.publicKey,
          '02956283a2d45d8964d20899dc10d0f53b8b9a87bd20ae0b029edf84bb924eb5ac');
      expect(walletNode.privateKey, 'L32Yu8bk1PNXFwvHqVL4mjnuXTo5MJQqQGD8H9Nyk3Ga87yzyiVP');
    });

    test('recoverUnparty5', () {
      String mnemonic = 'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';

      List<WalletNode> walletNodes = unipartyRecovery.recoverUniparty(mnemonic);

      WalletNode walletNode = walletNodes[0];

      expect(walletNode.address, 'bc1qlh65vz8w4jqc8y53ds82dyuctln3vncvuw6uwh');
      expect(walletNode.publicKey,
          '0359230c85d58221c312f7de64caee2b259152339049a1c68cfe3d2af239fe6f94');
      expect(walletNode.privateKey, 'L41jeNUoqXp4B7TS4EYh3PBBkfWYeBHkfQVZ46MfCiZHF9kKgViN');
    });
  });
}
