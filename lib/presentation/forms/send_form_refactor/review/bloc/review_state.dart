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

class ReviewModel with FormzMixin {
  final FormzSubmissionStatus status;
  final String? error;
  ReviewModel({
    required this.status,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [];

  ReviewModel copyWith({
    FormzSubmissionStatus? status,
    String? error,
  }) {
    return ReviewModel(
      status: status ?? this.status,
      error: error ?? this.error,
    );
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

class ReviewState {
  bool passwordRequired;
  bool showPasswordModal;
  ReviewModel formModel;
  PasswordFormModel passwordFormModel;

  ReviewState(
      {required this.passwordRequired,
      this.showPasswordModal = false,
      required this.formModel,
      required this.passwordFormModel});

  ReviewState copyWith(
      {bool? passwordRequired,
      bool? showPasswordModal,
      ReviewModel? formModel,
      PasswordFormModel? passwordFormModel}) {
    return ReviewState(
        showPasswordModal: showPasswordModal ?? this.showPasswordModal,
        passwordRequired: passwordRequired ?? this.passwordRequired,
        formModel: formModel ?? this.formModel,
        passwordFormModel: passwordFormModel ?? this.passwordFormModel);
  }
}
