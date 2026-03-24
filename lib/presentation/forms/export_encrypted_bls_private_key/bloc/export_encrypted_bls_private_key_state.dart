import "package:formz/formz.dart";
import "package:horizon/presentation/common/password_input.dart";

class ExportEncryptedBlsPrivateKeyState with FormzMixin {
  static const _sentinel = Object();

  final PasswordInput walletPassword;
  final PasswordInput exportPassword;
  final PasswordInput confirmExportPassword;
  final FormzSubmissionStatus submissionStatus;
  final String? encryptedBlsPrivateKey;
  final String? error;

  ExportEncryptedBlsPrivateKeyState({
    this.walletPassword = const PasswordInput.pure(),
    this.exportPassword = const PasswordInput.pure(),
    this.confirmExportPassword = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.encryptedBlsPrivateKey,
    this.error,
  });

  @override
  List<FormzInput> get inputs =>
      [walletPassword, exportPassword, confirmExportPassword];

  ExportEncryptedBlsPrivateKeyState copyWith({
    PasswordInput? walletPassword,
    PasswordInput? exportPassword,
    PasswordInput? confirmExportPassword,
    FormzSubmissionStatus? submissionStatus,
    String? encryptedBlsPrivateKey,
    Object? error = _sentinel,
  }) {
    return ExportEncryptedBlsPrivateKeyState(
      walletPassword: walletPassword ?? this.walletPassword,
      exportPassword: exportPassword ?? this.exportPassword,
      confirmExportPassword:
          confirmExportPassword ?? this.confirmExportPassword,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      encryptedBlsPrivateKey:
          encryptedBlsPrivateKey ?? this.encryptedBlsPrivateKey,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}
