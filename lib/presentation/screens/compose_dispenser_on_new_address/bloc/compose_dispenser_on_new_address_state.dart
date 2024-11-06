import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';

part 'compose_dispenser_on_new_address_state.freezed.dart';

@freezed
class ComposeDispenserOnNewAddressStateBase
    with _$ComposeDispenserOnNewAddressStateBase {
  const factory ComposeDispenserOnNewAddressStateBase({
    @Default(FeeState.initial()) feeState,
    @Default('') String password,
    @Default(ComposeDispenserOnNewAddressState.initial())
    composeDispenserOnNewAddressState,
  }) = _ComposeDispenserOnNewAddressStateBase;
}

@freezed
class ComposeDispenserOnNewAddressState<T>
    with _$ComposeDispenserOnNewAddressState {
  const factory ComposeDispenserOnNewAddressState.initial() =
      _ComposeDispenserOnNewAddressStateInitial;
  const factory ComposeDispenserOnNewAddressState.loading() =
      _ComposeDispenserOnNewAddressStateLoading;
  const factory ComposeDispenserOnNewAddressState.confirm({
    required T composeSendTransaction1,
    required T composeSendTransaction2,
    required T composeDispenserTransaction,
    required int fee,
    required int feeRate,
    required int totalVirtualSize,
    required int totalAdjustedVirtualSize,
  }) = _ComposeDispenserOnNewAddressStateConfirm;
  const factory ComposeDispenserOnNewAddressState.error(String error) =
      _ComposeDispenserOnNewAddressStateError;
  const factory ComposeDispenserOnNewAddressState.collectPassword(
      {String? error,
      bool? loading}) = _ComposeDispenserOnNewAddressStateCollectPassword;
}

/// FeeState represents the state of fee estimation.
@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
}

extension FeeStateGetOrThrow on FeeState {
  FeeEstimates feeEstimatesOrThrow() {
    return maybeWhen(
      success: (feeEstimates) => feeEstimates,
      orElse: () => throw StateError('FeeState is not in a success state'),
    );
  }
}
