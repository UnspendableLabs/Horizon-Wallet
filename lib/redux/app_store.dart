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

  AppState copyWith({
    required WalletRetrieveInfoState walletRetrieveInfoState,
  }) {
    return AppState(
      walletRetrieveInfoState: this.walletRetrieveInfoState,
    );
  }

  @override
  int get hashCode =>
      //isLoading.hash Code ^
      walletRetrieveInfoState.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState && walletRetrieveInfoState == other.walletRetrieveInfoState;
}
