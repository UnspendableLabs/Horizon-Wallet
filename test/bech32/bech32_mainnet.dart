import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('Test mainnet bech32', () {
    var bip32Util = Bip32();

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';

      WalletInfo address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 0, AddressType.bech32);
      // expect(address.address, '19syhrFjaYhH1nbhenwWaLKRm4BXbKgLRr');
      expect(address.publicKey,
          '033602c9263d18189c2bc67e7ef09ab7fbff3d3ed0c2c71516565637bcb8d166b4');
      expect(address.privateKey,
          'KzDAidSKrVYshLSuDmJtiYGcKo87xwkcEcJ4XAZhGC6GScpVtN2A');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'crowd assume laugh area stick visa cricket mountain industry sustain very mask';

      WalletInfo address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 0, AddressType.bech32);
      // expect(address.address, '14h1pWTt7jBNm7QVD4LTQ7dSU1ncS44W6N');
      expect(address.publicKey,
          '0379883a74a258be10bd69a037dbb85b765a78a73c60338a919848360fe8b8012a');
      expect(address.privateKey,
          'KwNscRcbDDDiCsjrkihQLSQsnrGxrnYK539nTLXTRiWWSMNmPSUV');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'fitness uncle finish promote car deny dish pact pepper bronze swift gallery';

      WalletInfo address = bip32Util.createBip32AddressFromSeed(
          mnemonic, 12, AddressType.bech32);
      // expect(address.address, '1LLmX9ksJhLSbtSFqu7V2h9LdMP4LWpnaW');
      expect(address.publicKey,
          '031dace6cae4dce49f05ca0e8d134a984b91475613f2011f461c2913f0bb9d24db');
      expect(address.privateKey,
          'KyNSGWtjo4VKsHjX9P6EqUbLbDU8a3DDGCwRKSHSn7m3sxGt3rXg');
    });

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'lecture job rare oil worth annual stem august doctor royal boring planet';

      WalletInfo address =
          bip32Util.createBip32AddressFromSeed(mnemonic, 2, AddressType.bech32);
      // expect(address.address, '16HKhrF9pCzKS6WTiVxt1H7ozAZKNCsyWS');
      expect(address.publicKey,
          '024ce3f08b4e7ef004365122349c11dbb0f6c6e1424b4801d173063ccbeaa10e5d');
      expect(address.privateKey,
          'L4TSYxrHvTPUP46yyuRoUJe2M4RV7ahU2APEn19id4caYr1xTWwk');
    });
  });
}
