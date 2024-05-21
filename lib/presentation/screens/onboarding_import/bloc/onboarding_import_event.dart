abstract class OnboardingImportEvent {} 

class MnemonicChanged extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicChanged({required this.mnemonic});
}

class ImportFormatChanged extends OnboardingImportEvent {
  final String importFormat;
  ImportFormatChanged({required this.importFormat});
}


class DeriveAddress extends OnboardingImportEvent {
  final String mnemonic;
  final String importFormat;
  DeriveAddress({required this.mnemonic, required this.importFormat});
}
