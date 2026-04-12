class ExportEncryptedBlsPrivateKeyEvent {}

class WalletPasswordChanged extends ExportEncryptedBlsPrivateKeyEvent {
  final String password;
  WalletPasswordChanged(this.password);
}

class ExportPasswordChanged extends ExportEncryptedBlsPrivateKeyEvent {
  final String password;
  ExportPasswordChanged(this.password);
}

class ConfirmExportPasswordChanged extends ExportEncryptedBlsPrivateKeyEvent {
  final String password;
  ConfirmExportPasswordChanged(this.password);
}

class ExportEncryptedBlsPrivateKeySubmitted
    extends ExportEncryptedBlsPrivateKeyEvent {}
