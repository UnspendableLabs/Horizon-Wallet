import 'package:horizon/domain/services/public_key_service.dart';

import 'package:horizon/domain/repositories/config_repository.dart';

import 'public_key_service_stub.dart'
    if (dart.library.io) 'public_key_service_native.dart'
    if (dart.library.html) 'public_key_service_web.dart';

PublicKeyService createPublicKeyService({
  required Config config,

  }) => createPublicKeyServiceImpl(config: config);
