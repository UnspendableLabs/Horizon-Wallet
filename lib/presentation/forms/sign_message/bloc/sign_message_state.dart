import "package:formz/formz.dart";

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.empty;
  }
}

class SignMessageState with FormzMixin {
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signature;
  // final String hash;
  // final String address;
  final String? error;

  SignMessageState({
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signature,
    this.error,
    // required this.hash,
    // required this.address
  });

  @override
  List<FormzInput> get inputs => [password];

  SignMessageState copyWith({
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signature,
    String? error,
    String? hash,
    String? address,
  }) {
    return SignMessageState(
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signature: signature ?? this.signature,
      error: error ?? this.error,
      // hash: hash ?? this.hash,
      // address: address ?? this.address,
    );
  }
}
