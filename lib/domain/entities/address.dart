class Address {
  final String accountUuid;
  final String address;
  final int addressIndex;
  final String publicKey;
  final String privateKeyWif;
  const Address(
      {required this.accountUuid,
      required this.address,
      required this.addressIndex,
      required this.publicKey,
      required this.privateKeyWif});
}
