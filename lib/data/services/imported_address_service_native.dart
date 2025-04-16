import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';

class ImportedAddressServiceNative implements ImportedAddressService {
  final Config config;
  ImportedAddressServiceNative({required this.config});

  @override
  Future<String> getAddressPrivateKeyFromWIF({required String wif}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getAddressFromWIF(
      {required String wif, required ImportAddressPkFormat format}) async {
    throw UnimplementedError();
  }
}
