enum ImportFormat {
  segwit("Segwit", "Segwit (BIP84,P2WPKH,Bech32)"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewallet("Freewallet-bech32", "Freewallet (Bech32 + Legacy)");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}
