import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
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
  final BalanceRepository balanceRepository = GetIt.I.get<BalanceRepository>();
  final AccountRepository accountRepository = GetIt.I.get<AccountRepository>();
  final AddressRepository addressRepository = GetIt.I.get<AddressRepository>();
  final AddressTxRepository addressTxRepository =
      GetIt.I.get<AddressTxRepository>();

  Timer? _timer;
  String accountUuid;

  BalancesBloc({required this.accountUuid})
      : super(const BalancesState.initial()) {
    on<Start>(_onStart);
    on<Stop>(_onStop);
    on<Fetch>(_onFetch);
  }

  void _onStart(event, emit) {
    _timer?.cancel();
    _timer = Timer.periodic(event.pollingInterval, (timer) {
      add(Fetch(accountUuid: accountUuid));
    });
    // Fetch immediately on start
    add(Fetch(accountUuid: accountUuid));
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
      final List<Address> addresses =
          await addressRepository.getAllByAccountUuid(accountUuid);

      final List<Balance> balances = await balanceRepository
          .getBalancesForAddresses(addresses.map((a) => a.address).toList());

      final Map<String, Balance> aggregated =
          aggregateAndSortBalancesByAsset(balances);

      emit(BalancesState.complete(Result.ok(balances, aggregated)));
    } catch (e) {
      emit(BalancesState.complete(Result.error(e.toString())));
    }
  }
}
