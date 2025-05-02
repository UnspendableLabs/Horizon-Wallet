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

  WalletConfig copyWith({
    String? network,
    String? basePath,
    int? accountIndexStart,
    int? accountIndexEnd,
  }) {
    return WalletConfig(
      network: network ?? this.network,
      basePath: basePath ?? this.basePath,
      accountIndexStart: accountIndexStart ?? this.accountIndexStart,
      accountIndexEnd: accountIndexEnd ?? this.accountIndexEnd,
    );
  }
}
