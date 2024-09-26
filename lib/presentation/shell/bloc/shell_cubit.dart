import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';

import './shell_state.dart';

class ShellStateCubit extends Cubit<ShellState> {
  WalletRepository walletRepository;
  AccountRepository accountRepository;
  AddressRepository addressRepository;
  AnalyticsService analyticsService;

  ShellStateCubit(
      {required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository,
      required this.analyticsService})
      : super(const ShellState.initial());

  void initialize() async {
    print("call shell initialize");
    emit(const ShellState.loading());
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const ShellState.onboarding(Onboarding.initial()));
        return;
      }

      analyticsService.identify(wallet.uuid);

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

      print("shell success");
      emit(ShellState.success(ShellStateSuccess(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        currentAccountUuid: currentAccount.uuid,
        addresses: addresses,
        currentAddress: currentAddress,
      )));
    } catch (error) {
      print("shell error $error");
      rethrow;
      emit(ShellState.error(error.toString()));
    }
  }

  void initialized() {
     print("initialized");
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
    print("onboarding initial");
    emit(const ShellState.onboarding(Onboarding.initial()));
  }

  void onOnboardingCreate() {
    print("onboarding create");
    emit(const ShellState.onboarding(Onboarding.create()));
  }

  void onOnboardingImport() {
    print("onboarding impoirt");
    emit(const ShellState.onboarding(Onboarding.import()));
  }

  void onOnboardingImportPK() {
    print("onboarding pk");
    emit(const ShellState.onboarding(Onboarding.importPK()));
  }

  void onAccountChanged(Account account) async {
    List<Address> addresses =
        await addressRepository.getAllByAccountUuid(account.uuid);

    print("on account changed");
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        onboarding: (_) => state,
        success: (stateInner) => ShellState.success(stateInner.copyWith(
            currentAccountUuid: account.uuid,
            currentAddress: addresses.first,
            addresses: addresses)));

    emit(state_);
  }

  void onAddressChanged(Address address) {
    print("on address changed");
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
    print("refresh");
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
      print("refresh error $error");
      rethrow;
      emit(ShellState.error(error.toString()));
    }
  }

  void refreshAndSelectNewAddress(String address, String accountUuid) async {
    print("refresh and sleect new address");
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

      Account? account = await accountRepository.getAccountByUuid(accountUuid);

      if (account == null) {
        throw Exception("invariant: no account for this uuid");
      }

      List<Address> addresses =
          await addressRepository.getAllByAccountUuid(account.uuid);

      if (addresses.isEmpty) {
        throw Exception("invariant: no addresses for this account");
      }

      Address newAddress = addresses.firstWhere((element) {
        return element.address == address;
      });

      emit(ShellState.success(ShellStateSuccess(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        addresses: addresses,
        currentAccountUuid: account.uuid,
        currentAddress: newAddress,
      )));
    } catch (error) {
      print("refresh and select new address $error");
      rethrow;

      emit(ShellState.error(error.toString()));
    }
  }
}
