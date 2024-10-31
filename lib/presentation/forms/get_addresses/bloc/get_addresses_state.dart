import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/address.dart';

enum AccountValidationError { empty }

class AccountInput extends FormzInput<String, AccountValidationError> {
  const AccountInput.pure() : super.pure('');
  const AccountInput.dirty([super.value = '']) : super.dirty();

  @override
  AccountValidationError? validator(String value) {
    return value.isNotEmpty ? null : AccountValidationError.empty;
  }
}

class GetAddressesState with FormzMixin {
  final AccountInput account;
  final FormzSubmissionStatus submissionStatus;
  final List<Address>? addresses;
  final String? error;

  GetAddressesState({
    this.account = const AccountInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.addresses,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [account];

  GetAddressesState copyWith({
    AccountInput? account,
    FormzSubmissionStatus? submissionStatus,
    List<Address>? addresses,
    String? error,
  }) {
    return GetAddressesState(
      account: account ?? this.account,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      addresses: addresses ?? this.addresses,
      error: error ?? this.error,
    );
  }
}
