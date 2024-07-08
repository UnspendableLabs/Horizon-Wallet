import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/remote_data_bloc/remote_data_cubit.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

import './shell_state.dart';

class ShellStateCubit extends Cubit<ShellState> {
  WalletRepository walletRepository;
  AccountRepository accountRepository;

  ShellStateCubit(
      {required this.walletRepository, required this.accountRepository})
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

      emit(ShellState.success(ShellStateSuccess(
          redirect: true,
          wallet: wallet,
          accounts: accounts,
          currentAccountUuid: accounts[0].uuid)));
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

  void refresh() async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const ShellState.onboarding(Onboarding.initial()));
        return;
      }

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);

      emit(ShellState.success(ShellStateSuccess(
          redirect: true,
          wallet: wallet,
          accounts: accounts,
          currentAccountUuid: accounts.last.uuid)));
    } catch (error) {
      emit(ShellState.error(error.toString()));
    }
  }
}
