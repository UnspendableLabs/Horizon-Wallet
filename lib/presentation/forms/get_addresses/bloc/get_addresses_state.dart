import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/domain/entities/imported_address.dart';

enum AddressSelectionMode { byAccount, importedAddresses }

enum AccountValidationError { empty }

class AccountInput extends FormzInput<String, AccountValidationError> {
  const AccountInput.pure() : super.pure('');
  const AccountInput.dirty([super.value = '']) : super.dirty();

  @override
  AccountValidationError? validator(String value) {
    return value.isNotEmpty ? null : AccountValidationError.empty;
  }
}

enum ImportedAddressValidationError { empty }

class ImportedAddressInput
    extends FormzInput<String, ImportedAddressValidationError> {
  const ImportedAddressInput.pure() : super.pure('');
  const ImportedAddressInput.dirty([super.value = '']) : super.dirty();

  @override
  ImportedAddressValidationError? validator(String value) {
    return value.isNotEmpty ? null : ImportedAddressValidationError.empty;
  }
}

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.empty;
  }
}

class GetAddressesState with FormzMixin {
  final PasswordInput password;
  final AccountInput account;
  final ImportedAddressInput importedAddress;
  final FormzSubmissionStatus submissionStatus;
  final List<AddressRpc>? addresses;
  final String? error;
  final AddressSelectionMode addressSelectionMode;
  final List<ImportedAddress>? importedAddresses;
  final bool warningAccepted;

  GetAddressesState({
    this.password = const PasswordInput.pure(),
    this.account = const AccountInput.pure(),
    this.importedAddress = const ImportedAddressInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.addresses,
    this.error,
    this.addressSelectionMode = AddressSelectionMode.byAccount,
    this.importedAddresses,
    this.warningAccepted = false,
  });

  @override
  List<FormzInput> get inputs => [password, account];

  GetAddressesState copyWith({
    PasswordInput? password,
    AccountInput? account,
    ImportedAddressInput? importedAddress,
    FormzSubmissionStatus? submissionStatus,
    List<AddressRpc>? addresses,
    String? error,
    AddressSelectionMode? addressSelectionMode,
    List<ImportedAddress>? importedAddresses,
    bool? warningAccepted,
  }) {
    return GetAddressesState(
      password: password ?? this.password,
      account: account ?? this.account,
      importedAddress: importedAddress ?? this.importedAddress,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      addresses: addresses ?? this.addresses,
      error: error ?? this.error,
      addressSelectionMode: addressSelectionMode ?? this.addressSelectionMode,
      importedAddresses: importedAddresses ?? this.importedAddresses,
      warningAccepted: warningAccepted ?? this.warningAccepted,
    );
  }
}
