import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/address.dart';
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

class GetAddressesState with FormzMixin {
  final AccountInput account;
  final ImportedAddressInput importedAddress; // New field
  final FormzSubmissionStatus submissionStatus;
  final List<Address>? addresses;
  final String? error;
  final AddressSelectionMode addressSelectionMode;
  final List<ImportedAddress>?
      importedAddresses; // Holds imported addresses for dropdown

  GetAddressesState({
    this.account = const AccountInput.pure(),
    this.importedAddress =
        const ImportedAddressInput.pure(), // Initialize as pure
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.addresses,
    this.error,
    this.addressSelectionMode = AddressSelectionMode.byAccount,
    this.importedAddresses,
  });

  @override
  List<FormzInput> get inputs => [account];

  GetAddressesState copyWith({
    AccountInput? account,
    ImportedAddressInput? importedAddress,
    FormzSubmissionStatus? submissionStatus,
    List<Address>? addresses,
    String? error,
    AddressSelectionMode? addressSelectionMode,
    List<ImportedAddress>? importedAddresses,
  }) {
    return GetAddressesState(
      account: account ?? this.account,
      importedAddress: importedAddress ?? this.importedAddress,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      addresses: addresses ?? this.addresses,
      error: error ?? this.error,
      addressSelectionMode: addressSelectionMode ?? this.addressSelectionMode,
      importedAddresses: importedAddresses ?? this.importedAddresses,
    );
  }
}
