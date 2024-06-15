class Account {
  String? walletUuid;
  String? uuid;
  String? name;
  String rootPublicKey;
  String rootPrivateKey; // TODO: obviously don't store PrivKey here

  Account({this.walletUuid, this.uuid, this.name, required this.rootPublicKey, required this.rootPrivateKey});
}
