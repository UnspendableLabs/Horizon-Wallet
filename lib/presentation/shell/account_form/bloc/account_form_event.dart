abstract class AccountFormEvent {}

class Submit extends AccountFormEvent {
  final String name;
  final String purpose;
  final String coinType;
  final String accountIndex;
  final String walletUuid;
  final String password;

  Submit({
    required this.name,
    required this.purpose,
    required this.coinType,
    required this.accountIndex,
    required this.walletUuid,
    required this.password,
  });
}
