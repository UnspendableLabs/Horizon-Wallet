import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_destroy_state.freezed.dart';

@freezed
class ComposeDestroyState with _$ComposeDestroyState, ComposeStateBase {
  const ComposeDestroyState._(); // Private constructor

  const factory ComposeDestroyState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeDestroyState;

  factory ComposeDestroyState.initial() => ComposeDestroyState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
