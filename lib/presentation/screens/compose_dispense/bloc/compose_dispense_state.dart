import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_dispense_state.freezed.dart';

@freezed
class ComposeDispenseState with _$ComposeDispenseState, ComposeStateBase {
  const ComposeDispenseState._(); // Added constructor for private use

  const factory ComposeDispenseState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
    required DispensersState dispensersState,

    // Specific properties
    Address? source,
    String? destination,
    String? asset,
    required String quantity,
    String? composeDispenseError,
  }) = _ComposeDispenseState;

  factory ComposeDispenseState.initial() => ComposeDispenseState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        dispensersState: const DispensersState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        quantity: '',
      );
}

@freezed
class DispensersState with _$DispensersState {
  const factory DispensersState.initial() = _DispensersInitial;
  const factory DispensersState.loading() = _DispensersLoading;
  const factory DispensersState.success(List<Dispenser> dispensers) =
      _DispensersSuccess;
  const factory DispensersState.error(String error) = _DispensersError;
}
