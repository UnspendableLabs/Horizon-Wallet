import 'package:horizon/common/constants.dart';

abstract class ImportedAddressService {
  Future<String> getAddressPrivateKeyFromWIF({
    required String wif,
  });
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
  });
}
