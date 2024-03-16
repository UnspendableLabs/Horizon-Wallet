import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('createBip32PubKeyPrivateKeyFromSeed mainnet', () {
    final bip32 = Bip32();
    final bip39 = Bip39();

    test('generates an expected public key and private key for index 0', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';

      String seed = bip39.mnemonicToEntropy(mnemonic);
      print('SEED $seed');
      KeyPair keyPair =
          bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seed)), 0);

      expect(hex.encode(keyPair.publicKey),
          '033602c9263d18189c2bc67e7ef09ab7fbff3d3ed0c2c71516565637bcb8d166b4');
      expect(keyPair.privateKey, 'KzDAidSKrVYshLSuDmJtiYGcKo87xwkcEcJ4XAZhGC6GScpVtN2A');
    });
  });
}
