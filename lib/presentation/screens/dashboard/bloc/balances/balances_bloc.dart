import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

// TODO: maybe abstract this away
import 'package:decimal/decimal.dart';

(Map<String, Balance>, List<Balance>) aggregateBalancesByAsset(
    List<Balance> balances) {
  var aggregatedBalances = <String, Balance>{};
  List<Balance> utxoBalances = [];

  for (var balance in balances) {
    if (balance.utxo != null) {
      utxoBalances.add(balance);
    } else {
      Balance agg = aggregatedBalances[balance.asset] ??
          Balance(
              asset: balance.asset,
              quantity: 0,
              quantityNormalized: '0',
              address: balance.address,
              assetInfo: balance.assetInfo,
              utxo: balance.utxo,
              utxoAddress: balance.utxoAddress);

      int nextQuantity = agg.quantity + balance.quantity;

      Decimal nextQuantityNormalizedDecimal =
          Decimal.parse(agg.quantityNormalized) +
              Decimal.parse(balance.quantityNormalized);

      String nextQuantityNormalized;
      if (balance.assetInfo.divisible) {
        nextQuantityNormalized =
            nextQuantityNormalizedDecimal.toStringAsFixed(8);
      } else {
        nextQuantityNormalized = nextQuantityNormalizedDecimal.toString();
      }

      Balance next = Balance(
          asset: balance.asset,
          quantity: nextQuantity,
          quantityNormalized: nextQuantityNormalized,
          address: balance.address,
          assetInfo: balance.assetInfo,
          utxo: balance.utxo,
          utxoAddress: balance.utxoAddress);

      aggregatedBalances[balance.asset] = next;
    }
  }

  return (aggregatedBalances, utxoBalances);
}

(Map<String, Balance>, List<Balance>) aggregateAndSortBalancesByAsset(
    List<Balance> balances) {
  var (aggregated, utxoBalances) = aggregateBalancesByAsset(balances);

  var sortedEntries = aggregated.entries.toList()
    ..sort((a, b) => b.value.quantity
        .compareTo(a.value.quantity)); // Sort by quantity descending

  var sortedUtxoBalances = utxoBalances.toList()
    ..sort((a, b) =>
        b.quantity.compareTo(a.quantity)); // Sort by quantity descending

  return (Map.fromEntries(sortedEntries), sortedUtxoBalances);
}

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final AddressTxRepository addressTxRepository;
  final AssetRepository assetRepository;
  final FairminterRepository fairminterRepository;
  final UtxoRepository utxoRepository;
  final String currentAddress;

  Timer? _timer;

  BalancesBloc({
    required this.balanceRepository,
    required this.accountRepository,
    required this.addressRepository,
    required this.addressTxRepository,
    required this.assetRepository,
    required this.fairminterRepository,
    required this.utxoRepository,
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
      final List<String> addresses = [currentAddress];

      final List<Balance> balances =
          await balanceRepository.getBalancesForAddresses(addresses);
      final (Map<String, Balance>, List<Balance>) allBalances =
          aggregateAndSortBalancesByAsset(balances);

      final Map<String, Balance> aggregated = allBalances.$1;
      final List<Balance> utxoBalances = allBalances.$2;

      final List<Utxo> utxos =
          await utxoRepository.getUnspentForAddress(currentAddress);

      final List<Asset> ownedAssets =
          await assetRepository.getValidAssetsByOwnerVerbose(currentAddress);

      final List<Fairminter> fairminters = await fairminterRepository
          .getFairmintersByAddress(currentAddress, 'open')
          .run()
          .then((either) => either.fold(
                (error) => throw FetchFairmintersException(
                    error.toString()), // Handle failure
                (fairminters) => fairminters, // Handle success
              ));

      emit(BalancesState.complete(Result.ok(balances, aggregated, utxoBalances,
          utxos, ownedAssets, fairminters)));
    } on FetchFairmintersException catch (e) {
      emit(BalancesState.complete(Result.error(
          "Error fetching fairminters for $currentAddress: ${e.message}")));
    } catch (e) {
      emit(BalancesState.complete(
          Result.error("Error fetching balances for $currentAddress")));
    }
  }

  @override
  Future<void> close() {
    // Cancel the timer to prevent adding events after the Bloc is closed
    _timer?.cancel();
    return super.close();
  }
}

class FetchFairmintersException implements Exception {
  final String message;
  FetchFairmintersException(this.message);

  @override
  String toString() => 'FetchFairmintersException: $message';
}
