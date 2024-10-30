import "package:formz/formz.dart";

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.empty;
  }
}

class SignPsbtState with FormzMixin {
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signedPsbt;
  final String? error;

  SignPsbtState({
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signedPsbt,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [password];

  SignPsbtState copyWith({
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signedPsbt,
    String? error,
  }) {
    return SignPsbtState(
        password: password ?? this.password,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        signedPsbt: signedPsbt ?? this.signedPsbt,
        error: error ?? this.error);
  }
}
