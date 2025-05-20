// data/services/platform_service_factory.dart

import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

import 'platform_service_stub.dart'
    if (dart.library.io) 'platform_service_native.dart'
    if (dart.library.html) 'platform_service_web.dart';

PlatformService createPlatformService({required Config config}) =>
    createPlatformServiceImpl(config: config);
