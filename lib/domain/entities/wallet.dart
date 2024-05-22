class Wallet {
  String accountUuid;
  String uuid;
  String publicKey;
  String wif; // TODO: obviously don't store WIF here

  Wallet(
      {required this.uuid,
      required this.accountUuid,
      required this.publicKey,
      required this.wif});
}


