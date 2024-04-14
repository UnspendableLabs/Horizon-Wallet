import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/pub_priv_key_utils/bip32_key_pair.dart';
import 'package:uniparty/bitcoin_wallet_utils/seed_utils/bip39.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/key_pair.dart';

void main() async {
  group('createBip32PubKeyPrivateKeyFromSeed testnet', () {
    final bip32 = Bip32();
    final bip39 = GetIt.I.get<Bip39Service>();

    test('generates an expected public key and private key for index 0', () {
      String mnemonic = 'trend pond enable empower govern example melody bless alone grow stone genre';

      Uint8List seedIntList = bip39.mnemonicToSeed(mnemonic);
      KeyPair keyPair = bip32.createBip32PubKeyPrivateKeyFromSeed(seedIntList, TESTNET, 0);

      expect(hex.encode(keyPair.publicKeyIntList), '033602c9263d18189c2bc67e7ef09ab7fbff3d3ed0c2c71516565637bcb8d166b4');
      expect(keyPair.privateKey, 'cQaABYSBHZF8rmvAcB825rmfx2RXdPrJJeSXdb2CmJkGhMsj5Csh');
    });

    test('generates an expected public key and private key for index 0', () {
      String mnemonic = 'crowd assume laugh area stick visa cricket mountain industry sustain very mask';

      Uint8List seedIntList = bip39.mnemonicToSeed(mnemonic);
      KeyPair keyPair = bip32.createBip32PubKeyPrivateKeyFromSeed(seedIntList, TESTNET, 0);

      expect(hex.encode(keyPair.publicKeyIntList), '0379883a74a258be10bd69a037dbb85b765a78a73c60338a919848360fe8b8012a');
      expect(keyPair.privateKey, 'cMjs5LcSeGuyNKD898WXhkuwR5aNXEe195JFZkyxvqAWh6TiErf6');
    });

    test('generates an expected public key and private key for index 12', () {
      String mnemonic = 'fitness uncle finish promote car deny dish pact pepper bronze swift gallery';

      Uint8List seedIntList = bip39.mnemonicToSeed(mnemonic);
      KeyPair keyPair = bip32.createBip32PubKeyPrivateKeyFromSeed(seedIntList, TESTNET, 12);

      expect(hex.encode(keyPair.publicKeyIntList), '031dace6cae4dce49f05ca0e8d134a984b91475613f2011f461c2913f0bb9d24db');
      expect(keyPair.privateKey, 'cPjRjRtbE8Bb2jCnXnuNCo6QDSmYEVJuLF5tRrjxHER48hQ6Zhn7');
    });

    test('generates an expected public key and private key for index 2', () {
      String mnemonic = 'lecture job rare oil worth annual stem august doctor royal boring planet';

      Uint8List seedIntList = bip39.mnemonicToSeed(mnemonic);
      KeyPair keyPair = bip32.createBip32PubKeyPrivateKeyFromSeed(seedIntList, TESTNET, 2);
      expect(hex.encode(keyPair.publicKeyIntList), '024ce3f08b4e7ef004365122349c11dbb0f6c6e1424b4801d173063ccbeaa10e5d');
      expect(keyPair.privateKey, 'cUpS1sr9MX5jYVaFNKEvqd95yHitn2oA6CXhtRcE8BGaob7rWKbM');
    });
  });
}
