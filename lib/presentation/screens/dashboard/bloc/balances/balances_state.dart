import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/balance.dart';

part "balances_state.freezed.dart";

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _Initial;
  const factory BalancesState.loading() = _Loading;
  const factory BalancesState.complete(Result result) = _Complete;
  const factory BalancesState.reloading(Result result) = _Reloading;
}

@freezed
class Result with _$Result {
  const factory Result.ok(
    // List<Balance> balances,
    Map<String, List<Balance>> aggregated,
    // List<Balance> utxoBalances,
    // List<Asset> ownedAssets,
    // List<Fairminter> fairminters
  ) = _Ok;
  const factory Result.error(String error) = _Error;
}
