enum AddressRpcType { p2pkh, p2wpkh, p2tr }

class AddressRpc {
  final String address;
  final String publicKey;
  final AddressRpcType type;

  const AddressRpc({
    required this.address,
    required this.publicKey,
    required this.type,
  });
}
