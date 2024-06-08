import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(AddressStateInitial) addressState,
    @Default(AccountStateInitial) accountState,
    @Default(WalletStateInitial) walletState,
  }) = _DashboardState;
}

abstract class AddressState {}

class AddressStateInitial extends AddressState {}

class AddressStateLoading extends AddressState {}

class AddressStateSuccess extends AddressState {
  final Address currentAddress;
  final List<Address> addresses;
  AddressStateSuccess({required this.currentAddress, required this.addresses});
}

class AddressStateError extends AddressState {
  final String message;
  AddressStateError({required this.message});
}

abstract class AccountState {}

class AccountStateInitial extends AccountState {}

class AccountStateLoading extends AccountState {}

class AccountStateSuccess extends AccountState {
  final Account currentAccount;
  AccountStateSuccess({required this.currentAccount});
}

class AccountStateError extends AccountState {}

abstract class WalletState {}

class WalletStateInitial extends WalletState {}

class WalletStateLoading extends WalletState {}

class WalletStateSuccess extends WalletState {
  final Wallet currentWallet;
  final List<Wallet> wallets;
  WalletStateSuccess({required this.wallets, required this.currentWallet});
}

class WalletStateError extends WalletState {
  final String message;
  WalletStateError({required this.message});
}
