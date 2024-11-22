import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_movetoutxo_state.freezed.dart';

@freezed
class ComposeMoveToUtxoState with _$ComposeMoveToUtxoState, ComposeStateBase {
  const ComposeMoveToUtxoState._(); // Added constructor for private use

  const factory ComposeMoveToUtxoState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeMoveToUtxoState;

  factory ComposeMoveToUtxoState.initial() => ComposeMoveToUtxoState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
