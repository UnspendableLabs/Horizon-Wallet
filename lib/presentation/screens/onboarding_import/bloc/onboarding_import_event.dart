abstract class OnboardingImportEvent {}

class MnemonicChanged extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicChanged({required this.mnemonic});
}

class ImportFormatChanged extends OnboardingImportEvent {
  final String walletType;
  ImportFormatChanged({required this.walletType});
}

class ImportFormatSubmitted extends OnboardingImportEvent {}

class MnemonicSubmittedted extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicSubmittedted({required this.mnemonic});
}

class ImportWallet extends OnboardingImportEvent {
  final String password;
  ImportWallet({required this.password});
}
