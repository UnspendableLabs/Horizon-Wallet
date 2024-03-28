import 'package:redux/redux.dart';
import 'package:uniparty/redux/app_store.dart';

class WalletRetrieveInfoViewModel {
  final bool isLoading;
  final String? seedHex;
  final String? walletType;

  WalletRetrieveInfoViewModel({
    required this.isLoading,
    this.seedHex,
    this.walletType,
  });

  static WalletRetrieveInfoViewModel fromStore(Store<AppState> store) {
    return WalletRetrieveInfoViewModel(
        isLoading: store.state.walletRetrieveInfoState.isLoading,
        seedHex: store.state.walletRetrieveInfoState.seedHex,
        walletType: store.state.walletRetrieveInfoState.walletType);
  }
}
