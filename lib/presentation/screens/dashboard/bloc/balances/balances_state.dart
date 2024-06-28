import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/balance.dart';

part "balances_state.freezed.dart";

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _Initial;
  const factory BalancesState.loading() = _Loading;
  const factory BalancesState.success(List<Balance> balances) = _Success;
  const factory BalancesState.error(String error) = _Error;
}






