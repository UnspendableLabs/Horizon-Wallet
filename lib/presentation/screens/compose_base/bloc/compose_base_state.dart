import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/submit_base_state.dart';

part 'compose_base_state.freezed.dart';

/// Mixin containing common state properties shared between ComposeIssuanceState and ComposeSendState.
mixin ComposeStateBase {
  FeeState get feeState;
  BalancesState get balancesState;
  FeeOption get feeOption;
  SubmitState get submitState;
}

/// FeeState represents the state of fee estimation.
@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
}

/// BalancesState represents the state of fetching balances.
@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalancesInitial;
  const factory BalancesState.loading() = _BalancesLoading;
  const factory BalancesState.success(List<Balance> balances) =
      _BalancesSuccess;
  const factory BalancesState.error(String error) = _BalancesError;
}

/// MaxValueState represents the state for calculating maximum transferable value.
@freezed
class MaxValueState with _$MaxValueState {
  const factory MaxValueState.initial() = _MaxValueInitial;
  const factory MaxValueState.loading() = _MaxValueLoading;
  const factory MaxValueState.success(int maxValue) = _MaxValueSuccess;
  const factory MaxValueState.error(String error) = _MaxValueError;
}
