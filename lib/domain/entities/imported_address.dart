class ImportedAddress {
  final String walletUuid;
  final String address;
  final int index;
  final String encryptedPrivateKey;

  const ImportedAddress({
    required this.walletUuid,
    required this.address,
    required this.index,
    required this.encryptedPrivateKey,
  });
}
