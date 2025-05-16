import "./get_addresses_state.dart";
import 'package:horizon/domain/entities/account_v2.dart';

abstract class GetAddressesEvent {}

class AccountChanged extends GetAddressesEvent {
  final AccountV2 account;
  AccountChanged(this.account);
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
