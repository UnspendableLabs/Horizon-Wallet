class SignPsbtEvent {}

class FetchFormEvent extends SignPsbtEvent {}

class PasswordChanged extends SignPsbtEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignPsbtSubmitted extends SignPsbtEvent {}

/// The user ticked (or unticked) the acknowledgement of the Counterparty
/// message a reveal carries.
class RevealAcknowledgementChanged extends SignPsbtEvent {
  final bool acknowledged;
  RevealAcknowledgementChanged(this.acknowledged);
}
