import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/counterwallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('CounterwalletRecovery', () {
    var counterwalletRecovery = CounterwalletRecovery();

    test('recoverFreewallet', () {
      const List<String> expectedAddress = [];
      String mnemonic = "threaten study pierce annoy leave wrote box drift drove soldier toss gasp";

      List<WalletInfo> wallets = counterwalletRecovery.recoverCounterwalletFromFreewallet(mnemonic);
      for (var wallet in wallets) {
        expect(expectedAddress.contains(wallet.address), true);
      }
    });
  });
}
