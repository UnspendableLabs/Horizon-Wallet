import 'package:redux/redux.dart';
import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/models/wallet_retrieve_info_state.dart';

// Reducer
AppState appReducer(state, action) {
  return AppState(walletRetrieveInfoState: walletRetrieveInfoReducer(state, action));
}

final walletRetrieveInfoReducer = combineReducers<WalletRetrieveInfoState>([
  TypedReducer<WalletRetrieveInfoState, WalletRetreiveInfoSaveAction>(_saveWalletRetrieveInfo).call,
  TypedReducer<WalletRetrieveInfoState, StartLoadingAction>(_startLoading).call,
]);

WalletRetrieveInfoState _saveWalletRetrieveInfo(
    WalletRetrieveInfoState state, WalletRetreiveInfoSaveAction action) {
  return state.copyWith(
    seedHex: action.seedHex,
    walletType: action.walletType,
    isLoading: false,
  );
}

WalletRetrieveInfoState _startLoading(WalletRetrieveInfoState state, StartLoadingAction action) {
  return state.copyWith(isLoading: true, seedHex: null, walletType: null);
}
