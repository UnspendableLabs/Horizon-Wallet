class GetBLSPoPEvent {}

class PasswordChanged extends GetBLSPoPEvent {
  final String password;
  PasswordChanged(this.password);
}

class GetBLSPoPSubmitted extends GetBLSPoPEvent {}
