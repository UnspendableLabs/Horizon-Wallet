// data/services/platform_service_stub.dart

import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PlatformServiceStub implements PlatformService {
  @override
  void openInNewTab() {
    throw UnimplementedError('openInNewTab is not supported on this platform.');
  }
}

PlatformService createPlatformServiceImpl({required Config config}) =>
    PlatformServiceStub();
