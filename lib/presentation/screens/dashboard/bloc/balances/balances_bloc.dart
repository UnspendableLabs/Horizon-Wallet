import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

/// A singleton version of BalancesBloc that persists data between navigations
class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  // Singleton instance
  static BalancesBloc? _instance;

  final BalanceRepository balanceRepository;
  Timer? _pollingTimer;
  List<String>? _currentAddresses;
  List<MultiAddressBalance>? _cachedBalances;

  // Get singleton instance
  static BalancesBloc getInstance({
    required List<String> addresses,
    BalanceRepository? repository,
  }) {
    _instance ??= BalancesBloc._(
      balanceRepository: repository ?? GetIt.I.get<BalanceRepository>(),
    );

    // Fix: Compare address contents, not references
    if (_instance!._currentAddresses?.join(',') != addresses.join(',')) {
      _instance!._currentAddresses = addresses;
      _instance!.add(Fetch());
    }

    return _instance!;
  }

  // Private constructor
  BalancesBloc._({
    required this.balanceRepository,
  }) : super(const BalancesState.initial()) {
    on<Fetch>(_onFetch);
    on<Start>(_onStart);
    on<Stop>(_onStop);
  }

  Future<void> _onFetch(Fetch event, Emitter<BalancesState> emit) async {
    if (_currentAddresses == null || _currentAddresses!.isEmpty) {
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
          await balanceRepository.getBalancesForAddresses(_currentAddresses!);

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

  // Helper method to compare two lists of MultiAddressBalance
  bool _areBalancesEqual(
      List<MultiAddressBalance> a, List<MultiAddressBalance> b) {
    if (a.length != b.length) return false;

    // Simple comparison of total assets and their quantities
    // For more detailed comparison, you might want to expand this
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
    // We don't want to close the singleton instance
    // Instead, we just stop the polling
    _pollingTimer?.cancel();
    _pollingTimer = null;

    // Don't call super.close() since we want to keep the bloc alive
    return Future.value();
  }

  // Method to force disposal (only for testing or app termination)
  void forceDispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _instance = null;
    super.close();
  }
}
