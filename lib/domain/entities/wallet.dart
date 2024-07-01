class Wallet {
  final String uuid;
  final String name;
  final String encryptedPrivKey;
  final String chainCodeHex;
  final String publicKey;
  const Wallet(
      {required this.uuid,
      required this.name,
      required this.encryptedPrivKey,
      required this.chainCodeHex,
      required this.publicKey});
}
