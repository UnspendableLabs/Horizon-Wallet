import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/models/wallet_retrieve_info_state.dart';

// Reducer
AppState appReducer(state, action) {
  return AppState(walletRetrieveInfoState: walletRetrieveInfoReducer(state, action));
}

walletRetrieveInfoReducer(AppState state, action) {
  if (action is WalletRetreiveInfoSaveAction) {
    return WalletRetrieveInfoState(seedHex: action.seedHex, walletType: action.walletType);
  }
  return WalletRetrieveInfoState.initial();
}
