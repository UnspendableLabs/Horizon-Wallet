import 'package:freezed_annotation/freezed_annotation.dart';

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

    // // Dispenser-specific properties
    // String? assetName,
    // String? openAddress,
  }) = _CloseDispenserState;

  factory CloseDispenserState.initial() => CloseDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
