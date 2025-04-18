import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';

class ImportedAddressServiceNative implements ImportedAddressService {
  final Config config;

  ImportedAddressServiceNative({required this.config});

  @override
  Future<String> getAddressPrivateKeyFromWIF({required String wif}) async {
    throw UnimplementedError(
      '[ImportedAddressServiceNative] getAddressPrivateKeyFromWIF() is not implemented for native platform.',
    );
  }

  @override
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
  }) async {
    throw UnimplementedError(
      '[ImportedAddressServiceNative] getAddressFromWIF() is not implemented for native platform.',
    );
  }
}

ImportedAddressService createImportedAddressServiceImpl({
  required Config config,
}) =>
    ImportedAddressServiceNative(config: config);
