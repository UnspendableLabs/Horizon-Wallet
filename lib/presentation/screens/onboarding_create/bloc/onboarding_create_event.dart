abstract class OnboardingCreateEvent {}

class PasswordChanged extends OnboardingCreateEvent {
  final String password;
  PasswordChanged({
    required this.password,
  });
}

class PasswordConfirmationChanged extends OnboardingCreateEvent {
  final String passwordConfirmation;
  PasswordConfirmationChanged({required this.passwordConfirmation});
}

class GoBackToMnemonic extends OnboardingCreateEvent {}

class GenerateMnemonic extends OnboardingCreateEvent {}

class UnconfirmMnemonic extends OnboardingCreateEvent {}

class PasswordError extends OnboardingCreateEvent {
  final String error;
  PasswordError({required this.error});
}

class ConfirmMnemonicChanged extends OnboardingCreateEvent {
  final String mnemonic;
  ConfirmMnemonicChanged({required this.mnemonic});
}

class ConfirmMnemonic extends OnboardingCreateEvent {
  final String mnemonic;
  ConfirmMnemonic({required this.mnemonic});
}

class MnemonicSubmit extends OnboardingCreateEvent {
  final String mnemonic;
  MnemonicSubmit({required this.mnemonic});
}

class CreateWallet extends OnboardingCreateEvent {}
