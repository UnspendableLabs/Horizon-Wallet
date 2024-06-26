import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/remote_data_bloc/remote_data_cubit.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

import './shell_state.dart' as shell_state;

class ShellStateCubit extends RemoteDataCubit< shell_state.ShellState> {
  WalletRepository walletRepository;
  AccountRepository accountRepository;

  ShellStateCubit(
      {required this.walletRepository, required this.accountRepository})
      : super(const RemoteDataState.initial());

  void initialize() async {
    emit(const RemoteDataState.loading());
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet!.uuid);

      emit(RemoteDataState.success(shell_state.ShellState(
          redirect: true,
          wallet: wallet,
          accounts: accounts,
          currentAccountUuid: accounts[0].uuid)));
    } catch (error) {
      emit(const RemoteDataState.success(shell_state.ShellState(
          redirect: true, wallet: null, accounts: [], currentAccountUuid: '')));
    }
  }

  void initialized() {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        success: (stateInner) =>
            RemoteDataState.success(stateInner.copyWith(redirect: false)));

    emit(state_ as RemoteDataState<shell_state.ShellState>);
  }

  void onAccountChanged(Account account) {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        success: (stateInner) =>
            RemoteDataState.success(stateInner.copyWith(currentAccountUuid: account.uuid)));

    emit(state_ as RemoteDataState<shell_state.ShellState>);
  }
}
