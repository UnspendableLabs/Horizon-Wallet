class Wallet {
  String accountUuid;
  String uuid;
  String name;
  String wif; // TODO: obviously don't store WIF here

  Wallet(
      {required this.uuid,
      required this.accountUuid,
      required this.name,
      required this.wif});
}


