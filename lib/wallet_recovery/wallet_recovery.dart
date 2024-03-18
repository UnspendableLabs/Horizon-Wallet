import 'package:uniparty/models/wallet_type_enum.dart';
import 'package:uniparty/wallet_recovery/counterwallet_recovery.dart';
import 'package:uniparty/wallet_recovery/freewallet_recovery.dart';
import 'package:uniparty/wallet_recovery/uniparty_recovery.dart';

void recoverWallet(String mnemonic, String walletType) {
  switch (walletType) {
    case UNIPARTY:
      UnipartyRecovery().recoverUniparty(mnemonic);
      break;
    case FREEWALLET:
      FreewalletRecovery().recoverFreewallet(mnemonic);
      break;
    case COUNTERWALLET:
      CounterwalletRecovery().recoverCounterwalletThroughFreewallet(mnemonic);
      break;
  }
}
