import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_dividend_state.freezed.dart';

@freezed
class ComposeDividendState with _$ComposeDividendState, ComposeStateBase {
  const ComposeDividendState._(); // Private constructor

  const factory ComposeDividendState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeDividendState;

  factory ComposeDividendState.initial() => ComposeDividendState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
