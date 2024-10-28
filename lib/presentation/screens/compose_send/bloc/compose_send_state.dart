import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_send_state.freezed.dart';

@freezed
class ComposeSendState with _$ComposeSendState, ComposeStateBase {
  const ComposeSendState._(); // Added constructor for private use

  const factory ComposeSendState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Specific properties
    required MaxValueState maxValue,
    required bool sendMax,
    String? source,
    String? destination,
    String? asset,
    required String quantity,
    String? composeSendError,
  }) = _ComposeSendState;

  factory ComposeSendState.initial() => ComposeSendState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        maxValue: const MaxValueState.initial(),
        sendMax: false,
        quantity: '',
      );
}

/// MaxValueState represents the state for calculating maximum transferable value.
@freezed
class MaxValueState with _$MaxValueState {
  const factory MaxValueState.initial() = _MaxValueInitial;
  const factory MaxValueState.loading() = _MaxValueLoading;
  const factory MaxValueState.success(int maxValue) = _MaxValueSuccess;
  const factory MaxValueState.error(String error) = _MaxValueError;
}
