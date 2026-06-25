abstract class SendTransferEvent {}

/// Compose the BTC send (fetch fee estimate + build the unsigned transaction).
class ComposeRequested extends SendTransferEvent {}

class PasswordChanged extends SendTransferEvent {
  final String password;
  PasswordChanged(this.password);
}

/// Sign and broadcast the composed transaction.
class ConfirmSend extends SendTransferEvent {}
