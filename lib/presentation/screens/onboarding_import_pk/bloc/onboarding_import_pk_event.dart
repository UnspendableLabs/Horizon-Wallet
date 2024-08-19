abstract class OnboardingImportPKEvent {}

class PasswordChanged extends OnboardingImportPKEvent {
  final String password;
  PasswordChanged({required this.password});
}

class PasswordConfirmationChanged extends OnboardingImportPKEvent {
  final String passwordConfirmation;
  PasswordConfirmationChanged({required this.passwordConfirmation});
}

class PasswordError extends OnboardingImportPKEvent {
  final String error;
  PasswordError({required this.error});
}

class PKChanged extends OnboardingImportPKEvent {
  final String pk;
  PKChanged({required this.pk});
}

class ImportFormatChanged extends OnboardingImportPKEvent {
  final String importFormat;
  ImportFormatChanged({required this.importFormat});
}

class PKSubmit extends OnboardingImportPKEvent {
  final String importFormat;
  final String pk;
  PKSubmit({required this.importFormat, required this.pk});
}

class ImportWallet extends OnboardingImportPKEvent {}
