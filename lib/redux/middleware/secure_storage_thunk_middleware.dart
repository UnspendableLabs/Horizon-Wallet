import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/utils/secure_storage.dart';

Future<Null> Function(Store<AppState> store) saveWalletRetrieveInfo(
    String seedHex, String walletType) {
  return (Store<AppState> store) async {
    Future(() async {
      final secureStorage = SecureStorage();
      await secureStorage.writeSecureData('seed_hex', seedHex);
      await secureStorage.writeSecureData('wallet_type', walletType);
      return;
    });
  };
}

ThunkAction saveInfoThunk(String seedHex, String walletType) {
  return (Store store) {
    Future(() {
      store.dispatch(WalletRetreiveInfoSaveAction(seedHex, walletType));
    });
  };
}
