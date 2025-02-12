class SignMessageEvent {}

class PasswordChanged extends SignMessageEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignMessageSubmitted extends SignMessageEvent {}
