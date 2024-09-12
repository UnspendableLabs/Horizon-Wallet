enum ImportFormat {
  horizon("Horizon", "Horizon Native"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewallet("Freewallet", "Freewallet (BIP39)"),

  counterwallet("Counterwallet", "Freewallet / Counterwallet");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}
