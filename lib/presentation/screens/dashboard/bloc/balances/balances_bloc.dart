import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

Map<String, List<Balance>> aggregateBalancesByAsset(List<Balance> balances) {
  var aggregatedBalances = <String, List<Balance>>{};

  for (var balance in balances) {
    aggregatedBalances[balance.assetInfo.assetLongname ?? balance.asset] ??= [];
    aggregatedBalances[balance.assetInfo.assetLongname ?? balance.asset]!
        .add(balance);
  }

  return aggregatedBalances;
}

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;
  final List<String> addresses;

  Timer? _timer;

  BalancesBloc({
    required this.balanceRepository,
    required this.addresses,
  }) : super(const BalancesState.initial()) {
    on<Start>(_onStart);
    on<Stop>(_onStop);
    on<Fetch>(_onFetch);
  }

  void _onStart(event, emit) {
    _timer?.cancel();
    _timer = Timer.periodic(event.pollingInterval, (timer) {
      add(Fetch());
    });
    // Fetch immediately on start
    add(Fetch());
  }

  void _onStop(event, emit) {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onFetch(event, emit) async {
    // emit loading if initial
    // emit reloading if complete

    state.map(
      initial: (_) => emit(const BalancesState.loading()),
      loading: (_) => null,
      complete: (completeState) =>
          emit(BalancesState.reloading(completeState.result)),
      reloading: (_) => null,
    );

    try {
      final List<Balance> balances =
          await balanceRepository.getBalancesForAddresses(addresses);
      final Map<String, List<Balance>> allBalances =
          aggregateBalancesByAsset(balances);

      emit(BalancesState.complete(Result.ok(allBalances)));
    } catch (e) {
      emit(BalancesState.complete(
          Result.error("Error fetching balances ${e.toString()}")));
    }
  }

  @override
  Future<void> close() {
    // Cancel the timer to prevent adding events after the Bloc is closed
    _timer?.cancel();
    return super.close();
  }
}
