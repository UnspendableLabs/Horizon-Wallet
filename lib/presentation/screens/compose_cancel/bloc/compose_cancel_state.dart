import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_cancel_state.freezed.dart';

@freezed
class ComposeCancelState with _$ComposeCancelState, ComposeStateBase {
  const ComposeCancelState._(); // Added constructor for private use

  const factory ComposeCancelState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeCancelState;

  factory ComposeCancelState.initial() => ComposeCancelState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
      );
}
