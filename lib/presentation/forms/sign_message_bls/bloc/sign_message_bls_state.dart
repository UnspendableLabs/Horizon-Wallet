import "package:formz/formz.dart";
import "package:horizon/presentation/common/password_input.dart";

class SignMessageBLSState with FormzMixin {
  static const _sentinel = Object();

  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signature;
  final String? publicKey;
  final String message;
  final String? dst;
  final String? error;

  SignMessageBLSState({
    required this.message,
    this.dst,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signature,
    this.publicKey,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [password];

  SignMessageBLSState copyWith({
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signature,
    String? publicKey,
    Object? error = _sentinel,
  }) {
    return SignMessageBLSState(
      message: message,
      dst: dst,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signature: signature ?? this.signature,
      publicKey: publicKey ?? this.publicKey,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}
