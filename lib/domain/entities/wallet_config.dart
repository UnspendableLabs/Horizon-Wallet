class WalletConfig {
  String network;
  String basePath;
  int accountIndexStart;
  int accountIndexEnd;

  WalletConfig(
      {required this.network,
      required this.basePath,
      this.accountIndexStart = 0,
      required this.accountIndexEnd});
}
