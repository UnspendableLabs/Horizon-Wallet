abstract class OnboardingImportEvent {}

class MnemonicChanged extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicChanged({required this.mnemonic});
}

class ImportFormatChanged extends OnboardingImportEvent {
  final String importFormat;
  ImportFormatChanged({required this.importFormat});
}

class ProceedToSeedInput extends OnboardingImportEvent {}

class ProceedToPasswordInput extends OnboardingImportEvent {
  final String mnemonic;
  ProceedToPasswordInput({required this.mnemonic});
}

class ImportWallet extends OnboardingImportEvent {
  final String password;
  ImportWallet({required this.password});
}
