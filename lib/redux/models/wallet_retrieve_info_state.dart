import 'package:meta/meta.dart';

@immutable
class WalletRetrieveInfoState {
  final String? seedHex;
  final String? walletType;

  const WalletRetrieveInfoState({
    @required this.seedHex,
    @required this.walletType,
  });

  factory WalletRetrieveInfoState.initial() {
    return const WalletRetrieveInfoState(seedHex: null, walletType: null);
  }
}
