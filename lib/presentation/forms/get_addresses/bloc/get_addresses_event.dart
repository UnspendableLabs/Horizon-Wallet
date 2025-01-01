import "./get_addresses_state.dart";

abstract class GetAddressesEvent {}

class AccountChanged extends GetAddressesEvent {
  final String accountUuid;
  AccountChanged(this.accountUuid);
}

class GetAddressesSubmitted extends GetAddressesEvent {}

class AddressSelectionModeChanged extends GetAddressesEvent {
  final AddressSelectionMode mode;
  AddressSelectionModeChanged(this.mode);
}

class ImportedAddressSelected extends GetAddressesEvent {
  final String address;
  ImportedAddressSelected(this.address);
}

class PasswordChanged extends GetAddressesEvent {
  final String password;
  PasswordChanged(this.password);
}

class WarningAcceptedChanged extends GetAddressesEvent {
  final bool accepted;
  WarningAcceptedChanged(this.accepted);
}
