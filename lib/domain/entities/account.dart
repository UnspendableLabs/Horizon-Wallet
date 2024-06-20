class Account {
  final String uuid;
  final String name;
  final String walletUuid;
  final String purpose;
  final int coinType;
  final int accountIndex;
  String xPub;
  Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.purpose,
      required this.coinType,
      required this.accountIndex,
      required this.xPub});
}
