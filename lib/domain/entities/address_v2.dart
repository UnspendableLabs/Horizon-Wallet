import 'package:horizon/domain/entities/address_rpc.dart';

enum AddressV2Type {
  p2pkh,
  p2wpkh,
}

class AddressV2 {
  final AddressV2Type type;
  final String address;
  final String path;
  final String publicKey;
  const AddressV2({
    required this.type,
    required this.address,
    required this.path,
    required this.publicKey,
  });
}

extension AddressV2X on AddressV2 {
  AddressRpc toRpc() {
    return AddressRpc(
      address: address,
      publicKey: publicKey,
      type: switch (type) {
        AddressV2Type.p2pkh => AddressRpcType.p2pkh,
        AddressV2Type.p2wpkh => AddressRpcType.p2wpkh,
      },
    );
  }
}
