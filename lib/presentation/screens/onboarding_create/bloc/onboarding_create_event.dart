abstract class OnboardingCreateEvent {}

class MnemonicBackPressed extends OnboardingCreateEvent {}

class MnemonicGenerated extends OnboardingCreateEvent {}

class MnemonicCreated extends OnboardingCreateEvent {}

class ConfirmMnemonicBackPressed extends OnboardingCreateEvent {}

class MnemonicConfirmedChanged extends OnboardingCreateEvent {
  final String mnemonic;
  MnemonicConfirmedChanged({required this.mnemonic});
}

class MnemonicConfirmed extends OnboardingCreateEvent {
  final List<String> mnemonic;
  MnemonicConfirmed({required this.mnemonic});
}

class WalletCreated extends OnboardingCreateEvent {
  final String password;
  WalletCreated({required this.password});
}
