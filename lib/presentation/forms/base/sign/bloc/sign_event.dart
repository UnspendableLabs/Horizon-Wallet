import 'package:equatable/equatable.dart';

abstract class SignEvent extends Equatable {
  const SignEvent();
  @override
  List<Object?> get props => [];
}

class PasswordPromptCancelClicked extends SignEvent {}

class PasswordPromptSubmitted extends SignEvent {
  final String password;
  const PasswordPromptSubmitted(this.password);
}

class SignAndSubmitClicked extends SignEvent {
  const SignAndSubmitClicked();
}
