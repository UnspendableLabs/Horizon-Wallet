class SignPsbtEvent {}

class FetchFormEvent extends SignPsbtEvent {}

class PasswordChanged extends SignPsbtEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignPsbtSubmitted extends SignPsbtEvent {}
