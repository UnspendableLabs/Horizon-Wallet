import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/address.dart';

part "addresses_state.freezed.dart";

// @freezed
// class PasswordPromptState with _$PasswordPromptState {
//   const factory PasswordPromptState.initial() = _PasswordInitial;
//   const factory PasswordPromptState.loading() = _PasswordLoading;
//   const factory PasswordPromptState.success() = _PasswordSuccess;
//   const factory PasswordPromptState.error(String error) = _PasswordError;
// }

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _Initial;
  const factory AddressesState.loading() = _Loading;
  const factory AddressesState.success(List<Address> addresses) = _Success;
  const factory AddressesState.error(String error) = _Error;
}
