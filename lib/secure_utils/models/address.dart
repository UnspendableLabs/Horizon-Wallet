enum AddressType { normal, bech32 }

class Address {
  String address;
  String publicKey;
  String privateKey;

  Address({
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}
