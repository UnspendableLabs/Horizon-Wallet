abstract class OnboardingCreateEvent {}

class GoBackToMnemonic extends OnboardingCreateEvent {}

class GenerateMnemonic extends OnboardingCreateEvent {}

class UnconfirmMnemonic extends OnboardingCreateEvent {}

class ConfirmMnemonicChanged extends OnboardingCreateEvent {
  final List<String> mnemonic;
  ConfirmMnemonicChanged({required this.mnemonic});
}

class ConfirmMnemonic extends OnboardingCreateEvent {
  final List<String> mnemonic;
  ConfirmMnemonic({required this.mnemonic});
}

class MnemonicSubmit extends OnboardingCreateEvent {
  final String mnemonic;
  MnemonicSubmit({required this.mnemonic});
}

class CreateWallet extends OnboardingCreateEvent {
  final String password;
  CreateWallet({required this.password});
}
