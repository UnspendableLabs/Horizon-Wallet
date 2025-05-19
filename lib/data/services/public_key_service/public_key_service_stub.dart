// data/services/public_key_service_stub.dart

import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PublicKeyServiceStub implements PublicKeyService {
  @override
  Future<String> fromPrivateKeyAsHex(String privateKey) {
    throw UnimplementedError(
        'fromPrivateKeyAsHex is not supported on this platform.');
  }
}

PublicKeyService createPublicKeyServiceImpl({required Config config}) =>
    PublicKeyServiceStub();
