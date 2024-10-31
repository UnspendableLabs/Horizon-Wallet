class ImportedAddress {
  final String address;
  final String name;
  final String encryptedWif;

  const ImportedAddress({
    required this.address,
    required this.encryptedWif,
    required this.name,
  });
}
