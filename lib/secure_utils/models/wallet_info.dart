enum AddressType { normal, bech32 }

class WalletInfo {
  String address;
  String publicKey;
  String privateKey;

  WalletInfo({
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}
