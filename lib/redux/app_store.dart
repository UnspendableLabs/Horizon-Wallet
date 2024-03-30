import 'package:meta/meta.dart';

import 'models/wallet_retrieve_info_state.dart';

@immutable
class AppState {
  final WalletRetrieveInfoState walletRetrieveInfoState;

  const AppState({required this.walletRetrieveInfoState});

  factory AppState.initial() {
    return AppState(
      walletRetrieveInfoState: WalletRetrieveInfoState.initial(),
    );
  }
}
