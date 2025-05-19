import 'package:horizon/domain/entities/network.dart';

class ImportedAddress {
  final Network network;
  final String encryptedWif;

  const ImportedAddress({
    required this.network,
    required this.encryptedWif,
  });
}
