import 'package:redux/redux.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/middleware/secure_storage_thunk_middleware.dart';

class WalletRetrieveInfoViewModel {
  final bool isLoading;
  final String? seedHex;
  final String? walletType;

  final Function(String, String) saveInfo;

  WalletRetrieveInfoViewModel({
    required this.isLoading,
    this.seedHex,
    this.walletType,
    required this.saveInfo,
  });

  static WalletRetrieveInfoViewModel fromStore(Store<AppState> store) {
    return WalletRetrieveInfoViewModel(
        isLoading: store.state.walletRetrieveInfoState.isLoading,
        seedHex: store.state.walletRetrieveInfoState.seedHex,
        walletType: store.state.walletRetrieveInfoState.walletType,
        saveInfo: (String seedHex, String walletType) async {
          await store.dispatch(saveWalletRetrieveInfo(seedHex, walletType));
        });
  }
}
