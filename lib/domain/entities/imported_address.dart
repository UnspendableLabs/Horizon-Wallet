class ImportedAddress {
  final String walletUuid;
  final String address;
  final String name;
  final String encryptedPrivateKey;

  const ImportedAddress({
    required this.walletUuid,
    required this.address,
    required this.name,
    required this.encryptedPrivateKey,
  });
}
