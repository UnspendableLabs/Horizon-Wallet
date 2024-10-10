import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';

import 'package:horizon/domain/entities/fee_option.dart';
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
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        quantity: '',
      );
}

