import "package:formz/formz.dart";
import "package:horizon/presentation/common/password_input.dart";

class GetBLSPoPState with FormzMixin {
  static const _sentinel = Object();

  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String address;
  final String? xpubkey;
  final String? blsPubkey;
  final String? schnorrSig;
  final String? blsSig;
  final String? error;

  GetBLSPoPState({
    required this.address,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.xpubkey,
    this.blsPubkey,
    this.schnorrSig,
    this.blsSig,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [password];

  GetBLSPoPState copyWith({
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? xpubkey,
    String? blsPubkey,
    String? schnorrSig,
    String? blsSig,
    Object? error = _sentinel,
  }) {
    return GetBLSPoPState(
      address: address,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      xpubkey: xpubkey ?? this.xpubkey,
      blsPubkey: blsPubkey ?? this.blsPubkey,
      schnorrSig: schnorrSig ?? this.schnorrSig,
      blsSig: blsSig ?? this.blsSig,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}
