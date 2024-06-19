class Account {
  final String uuid;
  final String name;
  final String walletUuid;
  final String purposeUuid;
  final String coinUuid;
  final int accountIndex;
  String xPub;
  Account(
      {required this.uuid,
      required this.name,
      required this.walletUuid,
      required this.purposeUuid,
      required this.coinUuid,
      required this.accountIndex,
      required this.xPub});
}
