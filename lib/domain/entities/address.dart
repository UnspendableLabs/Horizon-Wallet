class Address {
  String? accountUuid;
  String address;
  String derivationPath;
  String publicKey;
  String privateKeyWif;

  Address(
      {this.accountUuid,
      required this.address,
      required this.derivationPath,
      required this.publicKey,
      required this.privateKeyWif});
}
