class ImportedAddress {
  final String walletUuid;
  final String address;
  final String name;
  final String encryptedWIF;

  const ImportedAddress({
    required this.walletUuid,
    required this.address,
    required this.encryptedWIF,
    required this.name,
  });
}
