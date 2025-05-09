import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_burn_state.freezed.dart';

@freezed
class ComposeBurnState with _$ComposeBurnState, ComposeStateBase {
  const ComposeBurnState._(); // Added constructor for private use

  const factory ComposeBurnState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeBurnState;

  factory ComposeBurnState.initial() => ComposeBurnState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
      );
}
