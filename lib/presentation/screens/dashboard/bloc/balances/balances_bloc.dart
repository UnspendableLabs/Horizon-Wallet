import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

/// BalancesBloc manages the loading and caching of cryptocurrency balances
class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;
  final List<String> addresses;
  final CacheProvider cacheProvider;
  Timer? _pollingTimer;
  List<MultiAddressBalance>? _cachedBalances;

  String starredAssetsKey = 'starredAssets';

  /// Create a BalancesBloc with repository and addresses to monitor
  BalancesBloc({
    required this.balanceRepository,
    required this.addresses,
    required this.cacheProvider,
  }) : super(const BalancesState.initial()) {
    on<Fetch>(_onFetch);
    on<Start>(_onStart);
    on<Stop>(_onStop);
    on<ToggleStarred>(_onToggleStarred);
  }

  Future<void> _onFetch(Fetch event, Emitter<BalancesState> emit) async {
    if (addresses.isEmpty) {
      emit(const BalancesState.complete(Result.ok([], [])));
      return;
    }

    final starredAssets = cacheProvider.getValue<List<String>>(
          starredAssetsKey,
        ) ??
        [];

    // If we have cached data, emit a reloading state
    if (_cachedBalances != null) {
      emit(BalancesState.reloading(Result.ok(_cachedBalances!, starredAssets)));
    } else {
      emit(const BalancesState.loading());
    }

    try {
      final balances =
          await balanceRepository.getBalancesForAddresses(addresses);

      // Only update state if the new data is different
      if (_cachedBalances == null ||
          !MultiAddressBalance.equals(_cachedBalances!, balances)) {
        _cachedBalances = balances;
        emit(BalancesState.complete(Result.ok(balances, starredAssets)));
      }
      // If data is the same, we don't emit a new state
    } catch (e) {
      emit(BalancesState.complete(
          Result.error('Error fetching balances: ${e.toString()}')));
    }
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

  void _onToggleStarred(ToggleStarred event, Emitter<BalancesState> emit) {
    final asset = event.asset;
    final balances = _cachedBalances;
    if (balances == null) return;

    final starredAssets = cacheProvider.getValue<List<String>>(
          starredAssetsKey,
        ) ??
        [];

    if (!starredAssets.contains(asset)) {
      starredAssets.add(asset);
    } else {
      starredAssets.remove(asset);
    }

    cacheProvider.setObject<List<String>>(starredAssetsKey, starredAssets);

    emit(BalancesState.complete(Result.ok(balances, starredAssets)));
  }
}
