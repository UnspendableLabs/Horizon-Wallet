class Address {
  final String accountUuid;
  final String address;
  final int index;
  final String? encryptedPrivateKey;
  const Address({
    required this.accountUuid,
    required this.address,
    required this.index,
    this.encryptedPrivateKey,
  });
}
