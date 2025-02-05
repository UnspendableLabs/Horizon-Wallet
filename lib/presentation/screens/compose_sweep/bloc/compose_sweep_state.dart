import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_sweep_state.freezed.dart';

@freezed
class ComposeSweepState with _$ComposeSweepState, ComposeStateBase {
  const ComposeSweepState._(); // Private constructor

  const factory ComposeSweepState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Sweep properties
    required SweepXcpFeeState sweepXcpFeeState,
  }) = _ComposeSweepState;

  factory ComposeSweepState.initial() => ComposeSweepState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
        sweepXcpFeeState: const SweepXcpFeeState.initial(),
      );
}

@freezed
class SweepXcpFeeState with _$SweepXcpFeeState {
  const factory SweepXcpFeeState.initial() = _SweepXcpFeeInitial;
  const factory SweepXcpFeeState.loading() = _SweepXcpFeeLoading;
  const factory SweepXcpFeeState.success(int dividendXcpFee) =
      _SweepXcpFeeSuccess;
  const factory SweepXcpFeeState.error(String error) = _SweepXcpFeeError;
}
