import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/freewallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('FreewalletRecovery', () {
    var freewalletRecovery = FreewalletRecovery();

    test('recoverFreewallet', () {
      const List<String> expectedAddress = [];
      String mnemonic = "threaten study pierce annoy leave wrote box drift drove soldier toss gasp";

      List<WalletInfo> wallets = freewalletRecovery.recoverFreewallet(mnemonic);
      for (var wallet in wallets) {
        expect(expectedAddress.contains(wallet.address), true);
      }
    });
  });
}
