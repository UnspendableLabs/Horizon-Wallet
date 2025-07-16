import 'package:horizon/domain/entities/address_rpc.dart';

enum AddressV2Type {
  p2pkh,
  p2wpkh,
}

extension AddressV2TypeFriendlyName on AddressV2Type {
  String get displayName {
    return switch (this) {
      AddressV2Type.p2pkh => "Legacy (P2PKH)",
      AddressV2Type.p2wpkh => "SegWit (P2WPKH)"
    };
  }
}

sealed class DerivationType {}

class Bip32Path extends DerivationType {
  final String value;
  Bip32Path({required this.value});
}

class WIF extends DerivationType {
  final String value;
  WIF({required this.value});
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

  String shortAddress({int first = 6, int last = 4}) {
    if (address.length <= first + last) return address;
    final start = address.substring(0, first);
    final end = address.substring(address.length - last);
    return '$start...$end';
  }
}
