import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_mpma_state.freezed.dart';

@freezed
class MpmaEntry with _$MpmaEntry {
  const factory MpmaEntry({
    required MaxValueState maxValue,
    required bool sendMax,
    String? source,
    String? destination,
    String? asset,
    required String quantity,
  }) = _MpmaEntry;

  factory MpmaEntry.initial() => const MpmaEntry(
        maxValue: MaxValueState.initial(),
        sendMax: false,
        quantity: '',
      );
}

@freezed
class ComposeMpmaState with _$ComposeMpmaState, ComposeStateBase {
  const ComposeMpmaState._();

  const factory ComposeMpmaState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Specific properties
    required List<MpmaEntry> entries,
    String? composeSendError,
  }) = _ComposeMpmaState;

  factory ComposeMpmaState.initial() => ComposeMpmaState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        entries: [MpmaEntry.initial()],
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
