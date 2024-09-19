import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';

part 'compose_issuance_state.freezed.dart';

@freezed
class ComposeIssuanceState with _$ComposeIssuanceState {
  const factory ComposeIssuanceState({
    @Default(FeeState.initial()) feeState,
    @Default(BalancesState.initial()) balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeIssuanceState;
}

@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
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

sealed class SubmitState {
  const SubmitState();
}

class SubmitInitial extends SubmitState {
  final bool loading;
  final String? error;

  const SubmitInitial({
    this.loading = false,
    this.error,
  });
}

class SubmitComposing extends SubmitState {
  final SubmitStateComposingIssuance submitStateComposingIssuance;
  const SubmitComposing(this.submitStateComposingIssuance);
}

class SubmitSuccess extends SubmitState {
  final String transactionHex;
  const SubmitSuccess({required this.transactionHex});
}

class SubmitFinalizing extends SubmitState {
  final ComposeIssuanceVerbose composeIssuance;
  final int fee;
  final bool loading;
  final String? error;

  SubmitFinalizing(
      {required this.loading,
      required this.error,
      required this.composeIssuance,
      required this.fee});

  SubmitFinalizing copyWith({
    required ComposeIssuanceVerbose composeIssuance,
    required int fee,
    required bool loading,
    required String? error,
  }) {
    return SubmitFinalizing(
      composeIssuance: composeIssuance,
      fee: fee,
      loading: loading,
      error: error,
    );
  }
}

class SubmitError extends SubmitState {
  final String error;
  const SubmitError(this.error);
}

class SubmitStateComposingIssuance {
  final ComposeIssuanceVerbose composeIssuance;
  final int virtualSize;
  final int fee;
  final int feeRate;
  SubmitStateComposingIssuance({
    required this.composeIssuance,
    required this.virtualSize,
    required this.fee,
    required this.feeRate,
  });
}

class SubmitStateFinalizing {
  final ComposeIssuanceVerbose composeIssuance;
  final int fee;
  SubmitStateFinalizing({required this.composeIssuance, required this.fee});
}
