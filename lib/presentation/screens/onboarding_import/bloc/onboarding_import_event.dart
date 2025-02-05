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

class MnemonicSubmitted extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicSubmitted({required this.mnemonic});
}

class ImportWallet extends OnboardingImportEvent {
  final String password;
  ImportWallet({required this.password});
}
