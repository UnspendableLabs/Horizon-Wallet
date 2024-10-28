class ImportedAddress {
  final String walletUuid;
  final String address;
  final String encryptedPrivateKey;
  final String name;

  const ImportedAddress({
    required this.walletUuid,
    required this.address,
    required this.encryptedPrivateKey,
    required this.name,
  });
}
