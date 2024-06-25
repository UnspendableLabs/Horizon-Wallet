import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';

import 'package:horizon/remote_data_bloc/remote_data_cubit.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

import './shell_state.dart' as shell_state;

class ShellStateCubit extends RemoteDataCubit<shell_state.ShellState> {
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

      if (accounts.isEmpty) {
        throw Exception('invariant');
      }

      emit(RemoteDataState.success(shell_state.ShellState(
        initialized: false,
        wallet: wallet,
        accounts: accounts,
      )));
    } catch (error) {
      emit(const RemoteDataState.error("Error initializing shell"));
    }
  }

  void initialized() {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        success: (state__) =>
            RemoteDataState.success(state__.copyWith(initialized: true)));

    emit(state_);
  }
}
