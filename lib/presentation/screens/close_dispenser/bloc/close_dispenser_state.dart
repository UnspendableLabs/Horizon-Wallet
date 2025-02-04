import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/dispenser.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'close_dispenser_state.freezed.dart';

@freezed
class CloseDispenserState with _$CloseDispenserState, ComposeStateBase {
  const CloseDispenserState._(); // Private constructor

  const factory CloseDispenserState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
    // required List

    // Close Dispenser-specific properties
    required DispenserState dispensersState,
  }) = _CloseDispenserState;

  factory CloseDispenserState.initial() => CloseDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
        dispensersState: const DispenserState.initial(),
      );
}

@freezed
class DispenserState with _$DispenserState {
  const factory DispenserState.initial() = _DispenserInitial;
  const factory DispenserState.loading() = _DispenserLoading;
  const factory DispenserState.success(List<Dispenser> dispensers) =
      _DispenserSuccess;
  const factory DispenserState.error(String error) = _DispenserError;
}
