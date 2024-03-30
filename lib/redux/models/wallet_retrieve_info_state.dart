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

  WalletRetrieveInfoState copyWith(
      {bool? isLoading, @required String? seedHex, @required String? walletType}) {
    return WalletRetrieveInfoState(isLoading: isLoading, seedHex: seedHex, walletType: walletType);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletRetrieveInfoState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          seedHex == other.seedHex &&
          walletType == other.walletType;

  @override
  int get hashCode => isLoading.hashCode ^ seedHex.hashCode;
}
