import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PublicKeyServiceNative implements PublicKeyService {
  final Config config;

  PublicKeyServiceNative({required this.config});

  @override
  Future<String> fromPrivateKeyAsHex(String privateKey) async {
    throw UnimplementedError(
      '[PublicKeyServiceNative] fromPrivateKeyAsHex() is not implemented for native platform.',
    );
  }
}

PublicKeyService createPublicKeyServiceImpl({required Config config}) =>
    PublicKeyServiceNative(config: config);
