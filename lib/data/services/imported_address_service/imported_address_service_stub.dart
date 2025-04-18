import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class ImportedAddressServiceStub implements ImportedAddressService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  Future<String> getAddressPrivateKeyFromWIF({required String wif}) =>
      Future.error(_unsupported('getAddressPrivateKeyFromWIF'));

  @override
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
  }) =>
      Future.error(_unsupported('getAddressFromWIF'));
}

ImportedAddressService createImportedAddressServiceImpl({ required Config config} ) =>
    ImportedAddressServiceStub();
