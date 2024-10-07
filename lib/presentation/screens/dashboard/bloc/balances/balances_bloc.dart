import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

// TODO: maybe abstract this away
import 'package:decimal/decimal.dart';

Map<String, Balance> aggregateBalancesByAsset(List<Balance> balances) {
  var aggregatedBalances = <String, Balance>{};

  for (var balance in balances) {
    Balance agg = aggregatedBalances[balance.asset] ??
        Balance(
            asset: balance.asset,
            quantity: 0,
            quantityNormalized: '0',
            address: balance.address,
            assetInfo: balance.assetInfo);

    int nextQuantity = agg.quantity + balance.quantity;

    String nextQuantityNormalized = (Decimal.parse(agg.quantityNormalized) +
            Decimal.parse(balance.quantityNormalized))
        .toString();

    Balance next = Balance(
        asset: balance.asset,
        quantity: nextQuantity,
        quantityNormalized: nextQuantityNormalized,
        address: balance.address,
        assetInfo: balance.assetInfo);

    aggregatedBalances[balance.asset] = next;
  }

  return aggregatedBalances;
}

Map<String, Balance> aggregateAndSortBalancesByAsset(List<Balance> balances) {
  var aggregated = aggregateBalancesByAsset(balances);

  var sortedEntries = aggregated.entries.toList()
    ..sort((a, b) => b.value.quantity
        .compareTo(a.value.quantity)); // Sort by quantity descending

  return Map.fromEntries(sortedEntries);
}

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final AddressTxRepository addressTxRepository;
  final AssetRepository assetRepository;
  final Address currentAddress;

  Timer? _timer;

  BalancesBloc({
    required this.balanceRepository,
    required this.accountRepository,
    required this.addressRepository,
    required this.addressTxRepository,
    required this.assetRepository,
    required this.currentAddress,
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
      final List<Address> addresses = [currentAddress];

      final List<Balance> balances = await balanceRepository
          .getBalancesForAddresses(addresses.map((a) => a.address).toList());

      final Map<String, Balance> aggregated =
          aggregateAndSortBalancesByAsset(balances);

      final List<Asset> assets = await assetRepository
          .getValidAssetsByOwnerVerbose(currentAddress.address);

      emit(BalancesState.complete(Result.ok(balances, aggregated, assets)));
    } catch (e) {
      emit(BalancesState.complete(Result.error(
          "Error fetching balances for ${currentAddress.address}")));
    }
  }
}
