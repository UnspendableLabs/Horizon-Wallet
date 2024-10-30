abstract class LogoutEvent {}

class InitiateLogout extends LogoutEvent {}

class UpdateUnderstandingConfirmation extends LogoutEvent {
  final bool hasConfirmed;
  UpdateUnderstandingConfirmation(this.hasConfirmed);
}

class UpdateResetConfirmationText extends LogoutEvent {
  final String text;
  UpdateResetConfirmationText(this.text);
}

class ConfirmLogout extends LogoutEvent {}
