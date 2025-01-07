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
  }) = _ComposeSweepState;

  factory ComposeSweepState.initial() => ComposeSweepState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
