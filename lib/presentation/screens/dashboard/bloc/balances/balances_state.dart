import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/transaction.dart';

part "balances_state.freezed.dart";

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _Initial;
  const factory BalancesState.loading() = _Loading;
  const factory BalancesState.success(
      {required List<AddressInfo> addressInfo, required AddressInfo currentAddressBalances}) = _Success;
  const factory BalancesState.error(String error) = _Error;
}

class AddressInfo {
  final Address address;
  final List<Balance> balances;
  final List<Transaction> transactions;

  AddressInfo({required this.address, required this.balances, required this.transactions});
}
