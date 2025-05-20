import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/entities/network.dart';

class ImportedAddressServiceStub implements ImportedAddressService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  Future<String> getAddressPrivateKeyFromWIF(
          {required String wif, required Network network}) =>
      Future.error(_unsupported('getAddressPrivateKeyFromWIF'));

  @override
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
    required Network network,
  }) =>
      Future.error(_unsupported('getAddressFromWIF'));
}

ImportedAddressService createImportedAddressServiceImpl() =>
    ImportedAddressServiceStub();
