class ImportedAddress {
  final String address;
  final String name;
  final String encryptedWIF;

  const ImportedAddress({
    required this.address,
    required this.encryptedWIF,
    required this.name,
  });
}
