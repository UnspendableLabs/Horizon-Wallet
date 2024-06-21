class Account {
  final String uuid;
  final String name;
  final String walletUuid;
  final String purpose;
  final String coinType;
  final String accountIndex;
  Account({
    required this.uuid,
    required this.name,
    required this.walletUuid,
    required this.purpose,
    required this.coinType,
    required this.accountIndex,
  });
}
