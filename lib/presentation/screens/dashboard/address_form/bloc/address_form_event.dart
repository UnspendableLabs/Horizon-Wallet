abstract class AddressFormEvent {}

class Reset extends AddressFormEvent {}

class Submit extends AddressFormEvent {
  final String accountUuid;
  final String password;
  Submit({
    required this.accountUuid,
    required this.password,
  });
}
