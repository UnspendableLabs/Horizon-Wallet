import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_dispenser_state.freezed.dart';

@freezed
class ComposeDispenserState with _$ComposeDispenserState, ComposeStateBase {
  const ComposeDispenserState._(); // Private constructor

  const factory ComposeDispenserState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Dispenser-specific properties
    String? assetName,
    String? openAddress,
    required String giveQuantity,
    required String escrowQuantity,
    required String mainchainrate,
    required int status,
  }) = _ComposeDispenserState;

  factory ComposeDispenserState.initial() => ComposeDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        giveQuantity: '',
        escrowQuantity: '',
        mainchainrate: '',
        status: 0,
      );
}

