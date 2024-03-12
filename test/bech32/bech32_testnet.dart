import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('Test testnet bech32', () {
    dotenv.testLoad(fileInput: '''ENV=testnet''');

    var bip32Util = Bip32();

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';

      Address address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 0, AddressType.bech32);
      expect(address.address, 'mpPvzuLiPa8Xnu5KNMutQFXkd3nEZScLTE');
      expect(address.publicKey,
          '033602c9263d18189c2bc67e7ef09ab7fbff3d3ed0c2c71516565637bcb8d166b4');
      expect(address.privateKey,
          'cQaABYSBHZF8rmvAcB825rmfx2RXdPrJJeSXdb2CmJkGhMsj5Csh');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'crowd assume laugh area stick visa cricket mountain industry sustain very mask';

      Address address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 0, AddressType.bech32);
      expect(address.address, 'mjCy7ZYrvkcdYDt6vdJqE2qmL1PKN1Xs7P');
      expect(address.publicKey,
          '0379883a74a258be10bd69a037dbb85b765a78a73c60338a919848360fe8b8012a');
      expect(address.privateKey,
          'cMjs5LcSeGuyNKD898WXhkuwR5aNXEe195JFZkyxvqAWh6TiErf6');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'fitness uncle finish promote car deny dish pact pepper bronze swift gallery';

      Address address = bip32Util.createBip32AddressFromSeed(
          mnemonic, 12, AddressType.bech32);
      expect(address.address, 'mzripCqr7imhNzusZU5rrcMfVLymGX6Urv');
      expect(address.publicKey,
          '031dace6cae4dce49f05ca0e8d134a984b91475613f2011f461c2913f0bb9d24db');
      expect(address.privateKey,
          'cPjRjRtbE8Bb2jCnXnuNCo6QDSmYEVJuLF5tRrjxHER48hQ6Zhn7');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'lecture job rare oil worth annual stem august doctor royal boring planet';

      Address address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 2, AddressType.bech32);
      expect(address.address, 'mkoGzuL8dERaDCz5S4wFqCL8rAA2FBEA15');
      expect(address.publicKey,
          '024ce3f08b4e7ef004365122349c11dbb0f6c6e1424b4801d173063ccbeaa10e5d');
      expect(address.privateKey,
          'cUpS1sr9MX5jYVaFNKEvqd95yHitn2oA6CXhtRcE8BGaob7rWKbM');
    });
  });
}
