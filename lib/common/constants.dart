enum ImportFormat {
  segwit("Segwit", "Segwit (BIP84,P2WPKH,Bech32)"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewallet(
      "Freewallet", "Freewallet (BIP44,P2WPKH,Bech32 + BIP44,P2PKH,Base58)"),

  counterwallet("Counterwallet", "Counterwallet (BIP44,P2PKH,Base58) ");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}
