import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';


part "shell_bloc.freezed.dart";

part "shell_state.dart";
part "shell_event.dart";


class ShellBloc extends Bloc<ShellEvent, ShellState> {

  final WalletRepository walletRepository;
  final AccountRepository accountRepository;

  ShellBloc({required this.walletRepository, required this.accountRepository}) : super(const ShellState()) {
    on<ShellEvent>((events, emit) async {
        await events.map(
          init: (e) => _init(e, emit),
        );
      });
  }

  _init(ShellEvent event, emit) async {
    emit(const ShellState(status: Status.loading));
    try {
      final wallet = await walletRepository.getCurrentWallet();
      final accounts = await accountRepository.getAccountsByWalletUuid(wallet!.uuid);
      if ( accounts.isEmpty ) {
        emit(const ShellState(status: Status.error));
        return;
      }
      emit(const ShellState(status: Status.success));
    } catch (e) {
      emit(const ShellState(status: Status.error));
    }
  }

}
                 
