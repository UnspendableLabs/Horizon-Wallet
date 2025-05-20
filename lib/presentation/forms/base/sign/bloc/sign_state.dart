import 'package:formz/formz.dart';

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure([super.value = '']) : super.pure();

  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }
    return null;
  }
}

class SignModel with FormzMixin {
  final FormzSubmissionStatus status;
  final String? error;
  final String? txHex;
  final String? txHash;
  SignModel({
    required this.status,
    this.error,
    this.txHex,
    this.txHash,
  });

  @override
  List<FormzInput> get inputs => [];

  SignModel copyWith({
    FormzSubmissionStatus? status,
    String? error,
    String? txHex,
    String? txHash,
  }) {
    return SignModel(
        status: status ?? this.status,
        error: error ?? this.error,
        txHex: txHex ?? this.txHex,
        txHash: txHash ?? this.txHash);
  }
}

class PasswordFormModel {
  final FormzSubmissionStatus status;
  final PasswordInput password;
  final String? error;

  PasswordFormModel({
    required this.status,
    required this.password,
    this.error,
  });

  PasswordFormModel copyWith({
    FormzSubmissionStatus? status,
    PasswordInput? password,
    String? error,
  }) {
    return PasswordFormModel(
      status: status ?? this.status,
      password: password ?? this.password,
      error: error ?? this.error,
    );
  }
}

class SignState {
  bool passwordRequired;
  bool showPasswordModal;
  SignModel formModel;
  PasswordFormModel passwordFormModel;

  SignState(
      {required this.passwordRequired,
      this.showPasswordModal = false,
      required this.formModel,
      required this.passwordFormModel});

  SignState copyWith(
      {bool? passwordRequired,
      bool? showPasswordModal,
      SignModel? formModel,
      PasswordFormModel? passwordFormModel}) {
    return SignState(
        showPasswordModal: showPasswordModal ?? this.showPasswordModal,
        passwordRequired: passwordRequired ?? this.passwordRequired,
        formModel: formModel ?? this.formModel,
        passwordFormModel: passwordFormModel ?? this.passwordFormModel);
  }
}
