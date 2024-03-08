import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/counterwallet_hd_wallet_util.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('Test HDWalletUtil mainnet', () {
    var counterwalletHDWalletUtil = CounterwalletHDWalletUtil();

    test('createBip32AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '82fe40a0c31ac27e19bc302c5ed322158cfdbeb78ed3577e89ecf73abb838670fe4a1d17d3914ea4df8de75c6e98fa87603f6578dffbb039b5680504f84b2a4b');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 0);

      Address address =
          counterwalletHDWalletUtil.createBip32AddressFromSeed(seedHex, path);
      // expect(address.address, '1B6yQRDXADzdyDxyK74cFY8vzV341o2fcg');
      // expect(address.publicKey,
      //     '02ff5e001258801f2a32ceb4702a4e0b2c8f68d2a4afc85a01d17a568b720ef12a');
      // expect(address.privateKey,
      // 'KxFniLGmDo8VMPFHXgB1tokQArFgXQtJKkUATWWqTMYL2TAg9EDt');
    });
  });
}
