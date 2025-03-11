import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

/// BalancesBloc manages the loading and caching of cryptocurrency balances
class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;
  final List<String> addresses;
  Timer? _pollingTimer;
  List<MultiAddressBalance>? _cachedBalances;

  /// Create a BalancesBloc with repository and addresses to monitor
  BalancesBloc({
    required this.balanceRepository,
    required this.addresses,
  }) : super(const BalancesState.initial()) {
    on<Fetch>(_onFetch);
    on<Start>(_onStart);
    on<Stop>(_onStop);
  }

  Future<void> _onFetch(Fetch event, Emitter<BalancesState> emit) async {
    if (addresses.isEmpty) {
      emit(const BalancesState.complete(Result.ok([])));
      return;
    }

    // If we have cached data, emit a reloading state
    if (_cachedBalances != null) {
      emit(BalancesState.reloading(Result.ok(_cachedBalances!)));
    } else {
      emit(const BalancesState.loading());
    }

    try {
      final balances =
          await balanceRepository.getBalancesForAddresses(addresses);

      // Only update state if the new data is different
      if (_cachedBalances == null ||
          !_areBalancesEqual(_cachedBalances!, balances)) {
        _cachedBalances = balances;
        emit(BalancesState.complete(Result.ok(balances)));
      }
      // If data is the same, we don't emit a new state
    } catch (e) {
      emit(BalancesState.complete(
          Result.error('Error fetching balances: ${e.toString()}')));
    }
  }

  bool _areBalancesEqual(
      List<MultiAddressBalance> a, List<MultiAddressBalance> b) {
    if (a.length != b.length) return false;

    // Simple comparison of total assets and their quantities
    final Map<String, String> aAssets = {
      for (var balance in a) balance.asset: balance.totalNormalized
    };

    for (var balance in b) {
      final aQuantity = aAssets[balance.asset];
      if (aQuantity == null || aQuantity != balance.totalNormalized) {
        return false;
      }
    }

    return true;
  }

  void _onStart(Start event, Emitter<BalancesState> emit) {
    // Stop any existing timer
    _pollingTimer?.cancel();

    // Start a new timer
    _pollingTimer = Timer.periodic(event.pollingInterval, (_) {
      add(Fetch());
    });

    // Trigger an immediate fetch
    add(Fetch());
  }

  void _onStop(Stop event, Emitter<BalancesState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }
}
