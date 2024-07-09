// TODO: research part of / equatable

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';

part 'onboarding_import_state.freezed.dart';

@freezed
class OnboardingImportState with _$OnboardingImportState {
  const factory OnboardingImportState({
    String? password,
    String? passwordError,
    @Default("") String mnemonic,
    @Default(ImportFormat.segwit) importFormat,
    @Default(GetAddressesStateNotAsked) getAddressesState,
    @Default({}) Map<Address, bool> isCheckedMap,
    @Default(ImportStateNotAsked) importState,
  }) = _OnboardingImportState;
  // String mnmeonic = "";
  // ImportFormat importFormat = ImportFormat.segwit;
  // GetAddressesState getAddressesState = GetAddressesStateNotAsked();
  // Map<Address, bool> isCheckedMap = {};
  // ImportState importState = ImportStateNotAsked();
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
