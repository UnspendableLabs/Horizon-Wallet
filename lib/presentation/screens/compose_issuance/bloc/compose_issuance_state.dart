import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';

part 'compose_issuance_state.freezed.dart';

@freezed
class ComposeIssuanceState with _$ComposeIssuanceState {
  const factory ComposeIssuanceState({
    @Default(AddressesState.initial()) addressesState,
    @Default(SubmitState.initial()) submitState,
    @Default(BalancesState.initial()) balancesState,
  }) = _ComposeIssuanceState;
}

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _AddressInitial;
  const factory AddressesState.loading() = _AddressLoading;
  const factory AddressesState.success(List<Address> addresses) =
      _AddressSuccess;
  const factory AddressesState.error(String error) = _AddressError;
}

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalanceInital;
  const factory BalancesState.loading() = _BalanceLoading;

  const factory BalancesState.success(List<Balance> balances) = _BalanceSuccess;
  const factory BalancesState.error(String error) = _BalanceError;
}

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _SubmitInitial;
  const factory SubmitState.loading() = _SubmitLoading;
  const factory SubmitState.composing(
          SubmitStateComposingIssuance submitStateComposingIssuance) =
      _SubmitComposing;
  const factory SubmitState.success(String transactionHex) = _SubmitSuccess;
  const factory SubmitState.error(String error) = _SubmitError;
}

class SubmitStateComposingIssuance {
  final ComposeIssuanceVerbose composeIssuance;
  final int virtualSize;
  final Map<String, double> feeEstimates;
  final String confirmationTarget;
  SubmitStateComposingIssuance(
      {required this.composeIssuance,
      required this.virtualSize,
      required this.feeEstimates,
      required this.confirmationTarget});
}
