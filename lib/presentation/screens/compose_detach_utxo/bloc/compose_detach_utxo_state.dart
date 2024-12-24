import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_detach_utxo_state.freezed.dart';

@freezed
class ComposeDetachUtxoState with _$ComposeDetachUtxoState, ComposeStateBase {
  const ComposeDetachUtxoState._(); // Added constructor for private use

  const factory ComposeDetachUtxoState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
  }) = _ComposeDetachUtxoState;

  factory ComposeDetachUtxoState.initial() => ComposeDetachUtxoState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
      );
}
