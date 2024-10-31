abstract class GetAddressesEvent {}

class AccountChanged extends GetAddressesEvent {
  final String accountUuid;
  AccountChanged(this.accountUuid);
}

class GetAddressesSubmitted extends GetAddressesEvent {}
