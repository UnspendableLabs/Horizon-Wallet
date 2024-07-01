abstract class OnboardingCreateEvent {}

class PasswordChanged extends OnboardingCreateEvent {
  final String password;
  final String passwordConfirmation;
  PasswordChanged({required this.password, required this.passwordConfirmation});
}

class GenerateMnemonic extends OnboardingCreateEvent {}

class CreateWallet extends OnboardingCreateEvent {}
