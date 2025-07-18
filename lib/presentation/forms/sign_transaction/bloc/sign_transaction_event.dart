class SignTransactionEvent {}

class FetchFormEvent extends SignTransactionEvent {}

class PasswordChanged extends SignTransactionEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignTransactionSubmitted extends SignTransactionEvent {}
