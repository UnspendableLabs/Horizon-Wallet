import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import "./balances_state.dart";
import "./balances_event.dart";

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;

  BalancesBloc({
    required this.balanceRepository,
  }) : super(const BalancesState.initial()) {
    on<Fetch>((event, emit) async {
      emit(const BalancesState.loading());

      List<Balance> balances = await balanceRepository.getBalances(
          event.addresses.map((address) => address.address).toList());

      emit(BalancesState.success(balances));

      try {} catch (error) {
        emit(BalancesState.error(error.toString()));
      }
    });
  }
}
