enum WalletType {
  horizon("Horizon", "Horizon Native"),
  bip32("BIP32", "Freewallet / Counterwallet / Rare Pepe Wallet");

  const WalletType(this.name, this.description);
  final String name;
  final String description;
}

enum ImportFormat {
  horizon("Horizon", "Horizon Native"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewallet("Freewallet", "Freewallet (BIP39)"),

  counterwallet("Counterwallet", "Freewallet / Counterwallet");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}

enum ImportAddressPkFormat {
  segwit("Segwit", "Segwit (bc1q)"),
  legacy("Legacy", "Legacy (1)");

  const ImportAddressPkFormat(this.name, this.description);
  final String name;
  final String description;
}

enum IssuanceActionType {
  reset,
  lockDescription,
  lockQuantity,
  changeDescription,
  issueMore,
  issueSubasset,
  transferOwnership,
  dividend
}

const String kInactivityDeadlineKey = 'inactivityDeadline';

const String onboardingErrorMessage =
    'Something went wrong while opening your wallet. Please reach out to support@unspendablelabs.com or the Horizon Telegram channel https://t.me/horizonxcp for support.';

enum BalanceType {
  all,
  utxo,
  address,
}
