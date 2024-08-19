import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';

import './shell_state.dart';

class ShellStateCubit extends Cubit<ShellState> {
  WalletRepository walletRepository;
  AccountRepository accountRepository;
  AddressRepository addressRepository;

  ShellStateCubit(
      {required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository})
      : super(const ShellState.initial());

  void initialize() async {
    emit(const ShellState.loading());
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const ShellState.onboarding(Onboarding.initial()));
        return;
      }

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);

      if (accounts.isEmpty) {
        throw Exception("invariant: no accounts for this wallet");
      }

      Account currentAccount = accounts.first;

      List<Address> addresses =
          await addressRepository.getAllByAccountUuid(currentAccount.uuid);

      if (addresses.isEmpty) {
        throw Exception("invariant: no addresses for this account");
      }

      Address currentAddress = addresses.first;

      emit(ShellState.success(ShellStateSuccess(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        currentAccountUuid: currentAccount.uuid,
        addresses: addresses,
        currentAddress: currentAddress,
      )));
    } catch (error) {
      emit(ShellState.error(error.toString()));
    }
  }

  void initialized() {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        onboarding: (_) => state,
        success: (stateInner) =>
            ShellState.success(stateInner.copyWith(redirect: false)));

    emit(state_);
  }

  void onOnboarding() {
    emit(const ShellState.onboarding(Onboarding.initial()));
  }

  void onOnboardingCreate() {
    emit(const ShellState.onboarding(Onboarding.create()));
  }

  void onOnboardingImport() {
    emit(const ShellState.onboarding(Onboarding.import()));
  }

  void onOnboardingImportPK() {
    emit(const ShellState.onboarding(Onboarding.importPK()));
  }

  void onAccountChanged(Account account) {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        onboarding: (_) => state,
        success: (stateInner) => ShellState.success(
            stateInner.copyWith(currentAccountUuid: account.uuid)));

    emit(state_);
  }

  void onAddressChanged(Address address) {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        onboarding: (_) => state,
        success: (stateInner) =>
            ShellState.success(stateInner.copyWith(currentAddress: address)));
    emit(state_);
  }

  void refresh() async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const ShellState.onboarding(Onboarding.initial()));
        return;
      }

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);

      if (accounts.isEmpty) {
        throw Exception("invariant: no accounts for this wallet");
      }

      List<Address> addresses =
          await addressRepository.getAllByAccountUuid(accounts.last.uuid);

      if (addresses.isEmpty) {
        throw Exception("invariant: no addresses for this account");
      }

      emit(ShellState.success(ShellStateSuccess(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        addresses: addresses,
        currentAccountUuid: accounts.last.uuid,
        currentAddress: addresses.first,
      )));
    } catch (error) {
      emit(ShellState.error(error.toString()));
    }
  }

  void refreshAndSelectNewAddress(String address) async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const ShellState.onboarding(Onboarding.initial()));
        return;
      }

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);

      if (accounts.isEmpty) {
        throw Exception("invariant: no accounts for this wallet");
      }

      List<Address> addresses =
          await addressRepository.getAllByAccountUuid(accounts.last.uuid);

      if (addresses.isEmpty) {
        throw Exception("invariant: no addresses for this account");
      }

      Address newAddress =
          addresses.firstWhere((element) => element.address == address);

      emit(ShellState.success(ShellStateSuccess(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        addresses: addresses,
        currentAccountUuid: accounts.last.uuid,
        currentAddress: newAddress,
      )));
    } catch (error) {
      emit(ShellState.error(error.toString()));
    }
  }
}
