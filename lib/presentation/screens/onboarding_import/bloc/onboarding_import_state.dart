import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';

part 'onboarding_import_state.freezed.dart';

enum ImportFormat {
  segwit("Segwit", "Segwit (BIP84,P2WPKH,Bech32)"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewalletBech32("Freewallet-bech32", "Freewallet (Bech32)");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}

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

class ImportStateLoading extends ImportState {}

class ImportStateSuccess extends ImportState {}

class ImportStateError extends ImportState {
  final String message;
  final String? stackTrace;
  ImportStateError({required this.message, this.stackTrace});
}
