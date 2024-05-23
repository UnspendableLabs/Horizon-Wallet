
import 'package:uniparty/domain/entities/address.dart';

abstract class OnboardingCreateEvent {}

class PasswordSubmit extends OnboardingCreateEvent {
  final String password;
  final String passwordConfirmation;
  PasswordSubmit({required this.password, required this.passwordConfirmation});

}

class GenerateMnemonic extends OnboardingCreateEvent {}

class CreateWallet extends OnboardingCreateEvent {}

