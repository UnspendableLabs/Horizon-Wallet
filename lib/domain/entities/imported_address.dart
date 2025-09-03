import 'package:horizon/domain/entities/network.dart';
import "package:horizon/domain/entities/address_v2.dart";

class ImportedAddress {
  final String address;
  final Network network;
  final String encryptedWif;
  final AddressV2Type type;

  const ImportedAddress({
    required this.address,
    required this.type,
    required this.network,
    required this.encryptedWif,
  });
}
