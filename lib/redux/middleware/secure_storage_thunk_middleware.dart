import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/utils/secure_storage.dart';

Future<Null> Function(Store<AppState> store) saveWalletRetrieveInfo(String seedHex, String walletType) {
  return (Store<AppState> store) async {
    Future(() async {
      final secureStorage = SecureStorage();
      print('WRITING TO STORAGE');
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

Future<Null> Function(Store<AppState> store) getWalletInfo(String? stateSeedHex, String? stateWalletType) {
  return (Store<AppState> store) async {
    Future(() async {
      // This method should run anytime we try to initialize state
      // if the seedHex and walletType are already saved to state, we're good to go (early return)
      // otherwise we should check to see if the seedHex and walletType are in secure storage and then set state
      if (stateSeedHex != null && stateWalletType != null) {
        return;
      }

      final secureStorage = SecureStorage();
      String? seedHex = await secureStorage.readSecureData('seed_hex');
      String? walletType = await secureStorage.readSecureData('wallet_type');

      if (seedHex != null && walletType != null) {
        store.dispatch(WalletRetreiveInfoSaveAction(seedHex, walletType));
      }
    });
  };
}
