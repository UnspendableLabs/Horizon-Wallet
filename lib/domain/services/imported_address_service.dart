import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/network.dart';

abstract class ImportedAddressService {
  Future<String> getAddressPrivateKeyFromWIF({
    required String wif,
    required Network network,
  });
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
    required Network network,
  });
}
