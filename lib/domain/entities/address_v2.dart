import 'package:horizon/domain/entities/address_rpc.dart';

enum AddressV2Type {
  p2pkh,
  p2wpkh,
}

sealed class DerivationType {}

class Bip32Path extends DerivationType {
  final String path;
  Bip32Path({required this.path});
}

class WIF extends DerivationType {
  final String wif;
  WIF({required this.wif});
}

class AddressV2 {
  final AddressV2Type type;
  final String address;
  final DerivationType derivation;
  final String publicKey;
  const AddressV2({
    required this.type,
    required this.address,
    required this.derivation,
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
