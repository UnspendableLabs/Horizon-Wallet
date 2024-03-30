import 'package:redux/redux.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/middleware/secure_storage_thunk_middleware.dart';

class WalletRetrieveInfoViewModel {
  final String? seedHex;
  final String? walletType;

  final Function(String, String) saveInfo;
  final Function(String, String) saveToState;

  WalletRetrieveInfoViewModel(
      {this.seedHex, this.walletType, required this.saveInfo, required this.saveToState});

  static WalletRetrieveInfoViewModel fromStore(Store<AppState> store) {
    return WalletRetrieveInfoViewModel(
        seedHex: store.state.walletRetrieveInfoState.seedHex,
        walletType: store.state.walletRetrieveInfoState.walletType,
        saveInfo: (String seedHex, String walletType) async {
          await store.dispatch(saveWalletRetrieveInfo(seedHex, walletType));
        },
        saveToState: (String seedHex, String walletType) {
          store.dispatch(saveInfoThunk(seedHex, walletType));
        });
  }
}
