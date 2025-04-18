import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_attach_utxo_state.freezed.dart';

@freezed
class ComposeAttachUtxoState with _$ComposeAttachUtxoState, ComposeStateBase {
  const ComposeAttachUtxoState._(); // Added constructor for private use

  const factory ComposeAttachUtxoState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Additional properties
    required String xcpFeeEstimate,
  }) = _ComposeAttachUtxoState;

  factory ComposeAttachUtxoState.initial() => ComposeAttachUtxoState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
        xcpFeeEstimate: '',
      );
}
