// TODO: research part of / equatable

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';

part 'onboarding_import_state.freezed.dart';

@freezed
class OnboardingImportState with _$OnboardingImportState {
  const factory OnboardingImportState({
    @Default("") String mnemonic,
    @Default(null) String? mnemonicError,
    @Default(ImportFormat.horizon) importFormat,
    @Default(GetAddressesStateNotAsked) getAddressesState,
    @Default({}) Map<Address, bool> isCheckedMap,
    @Default(ImportStateNotAsked) importState,
  }) = _OnboardingImportState;
}

abstract class GetAddressesState {}

class GetAddressesStateNotAsked extends GetAddressesState {}

class GetAddressesStateLoading extends GetAddressesState {}

class GetAddressesStateSuccess extends GetAddressesState {
  final List<Address> addresses;
  GetAddressesStateSuccess({required this.addresses});
}

class GetAddressesStateError extends GetAddressesState {
  final String message;
  GetAddressesStateError({required this.message});
}

abstract class ImportState {}

class ImportStateNotAsked extends ImportState {}

class ImportStateMnemonicCollected extends ImportState {}

class ImportStateLoading extends ImportState {}

class ImportStateSuccess extends ImportState {}

class ImportStateError extends ImportState {
  final String message;
  ImportStateError({required this.message});
}
