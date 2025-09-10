enum AddressRpcType { p2pkh, p2wpkh }

class AddressRpc {
  final String address;
  final String publicKey;
  final AddressRpcType type;
  final String uuid;

  const AddressRpc({
    required this.address,
    required this.publicKey,
    required this.type,
    required this.uuid,
  });
}
