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
    required DispenserState dispensersState,
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
        dispensersState: const DispenserState.initial(),
      );
}

@freezed
class DispenserState with _$DispenserState {
  const factory DispenserState.initial() = _DispenserInitial;
  const factory DispenserState.loading() = _DispenserLoading;
  const factory DispenserState.successNormalFlow() =
      _DispenserSuccessNormalFlow;
  const factory DispenserState.successCreateNewAddressFlow() =
      _DispenserSuccessCreateNewAddressFlow;
  const factory DispenserState.closeDialogAndOpenNewAddress(
      {required String originalAddress,
      required bool divisible,
      required String asset,
      required String giveQuantity,
      required String escrowQuantity,
      required String mainchainrate,
      required int feeRate}) = _DispenserCloseDialogAndOpenNewAddress;

  const factory DispenserState.warning() = _DispenserWarning;

  const factory DispenserState.error(String error) = _DispenserError;
}
