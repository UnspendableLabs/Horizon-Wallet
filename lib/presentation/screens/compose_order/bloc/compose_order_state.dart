import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_order_state.freezed.dart';

@freezed
class ComposeOrderState with _$ComposeOrderState, ComposeStateBase {
  const ComposeOrderState._(); // Added constructor for private use

  const factory ComposeOrderState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeOrderState;

  factory ComposeOrderState.initial() => ComposeOrderState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
