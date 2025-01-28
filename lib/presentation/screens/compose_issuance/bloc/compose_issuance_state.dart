import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_issuance_state.freezed.dart';

@freezed
class ComposeIssuanceState with _$ComposeIssuanceState, ComposeStateBase {
  const ComposeIssuanceState._(); // Added constructor for private use

  const factory ComposeIssuanceState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Specific properties
    String? assetName,
    String? assetDescription,
    required String quantity,
  }) = _ComposeIssuanceState;

  factory ComposeIssuanceState.initial() => ComposeIssuanceState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
        quantity: '',
      );
}
