abstract class AddressesEvent {}

class Update extends AddressesEvent {
  final String accountUuid;
  final int gapLimit;
  final String password;
  Update(
      {required this.accountUuid,
      required this.gapLimit,
      required this.password});
}

class GetAll extends AddressesEvent {
  final String accountUuid;
  GetAll({required this.accountUuid});
}
