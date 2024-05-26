class Wallet {
  String? accountUuid;
  String? uuid;
  String? name;
  String publicKey;
  String wif; // TODO: obviously don't store WIF here

  Wallet({this.uuid, this.accountUuid, this.name, required this.publicKey, required this.wif});
}
