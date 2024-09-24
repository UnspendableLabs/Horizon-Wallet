abstract class OnboardingImportPKEvent {}

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

class ImportWallet extends OnboardingImportPKEvent {
  final String password;
  ImportWallet({required this.password});
}
