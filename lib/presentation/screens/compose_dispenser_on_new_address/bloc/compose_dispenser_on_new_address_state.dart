import 'package:freezed_annotation/freezed_annotation.dart';

part 'compose_dispenser_on_new_address_state.freezed.dart';

@freezed
class ComposeDispenserOnNewAddressState
    with _$ComposeDispenserOnNewAddressState {
  const factory ComposeDispenserOnNewAddressState.initial() =
      _ComposeDispenserOnNewAddressStateInitial;
  const factory ComposeDispenserOnNewAddressState.loading() =
      _ComposeDispenserOnNewAddressStateLoading;
  const factory ComposeDispenserOnNewAddressState.success() =
      _ComposeDispenserOnNewAddressStateSuccess;
  const factory ComposeDispenserOnNewAddressState.error(String error) =
      _ComposeDispenserOnNewAddressStateError;
  const factory ComposeDispenserOnNewAddressState.collectPassword(
      {String? error}) = _ComposeDispenserOnNewAddressStateCollectPassword;
}
