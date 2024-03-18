enum AddressType { normal, bech32 }

class WalletNode {
  String address;
  String publicKey;
  String privateKey;

  WalletNode({
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}
