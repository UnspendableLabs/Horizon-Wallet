import 'package:meta/meta.dart';

@immutable
class WalletRetrieveInfoState {
  final bool? isLoading;
  final String? seedHex;
  final String? walletType;

  const WalletRetrieveInfoState({
    this.isLoading,
    @required this.seedHex,
    @required this.walletType,
  });

  factory WalletRetrieveInfoState.initial() {
    return const WalletRetrieveInfoState(isLoading: false, seedHex: null, walletType: null);
  }
}
