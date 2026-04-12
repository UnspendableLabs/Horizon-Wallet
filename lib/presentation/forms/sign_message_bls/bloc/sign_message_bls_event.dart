class SignMessageBLSEvent {}

class PasswordChanged extends SignMessageBLSEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignMessageBLSSubmitted extends SignMessageBLSEvent {}
