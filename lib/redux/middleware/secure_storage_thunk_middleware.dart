import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/utils/secure_storage.dart';

ThunkAction saveWalletRetrieveInfo(String seedHex, String walletType) {
  return (Store store) async {
    Future(() async {
      print('DO WE GET HERe');
      store.dispatch(StartLoadingAction());
      final secureStorage = SecureStorage();
      await secureStorage.writeSecureData('seed_hex', seedHex);
      await secureStorage.writeSecureData('wallet_type', walletType);
      store.dispatch(WalletRetreiveInfoSaveAction(seedHex, walletType));
    });
  };
}
