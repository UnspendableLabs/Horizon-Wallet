class ImportedAddress {
  final String walletUuid;
  final String address;
  final String name;
  final String encryptedWif;

  const ImportedAddress({
    required this.walletUuid,
    required this.address,
    required this.encryptedWif,
    required this.name,
  });
}
