// data/services/encryption_service_factory.dart

import 'package:horizon/domain/services/encryption_service.dart';

import './encryption_service_stub.dart'
    if (dart.library.io) './encryption_service_native.dart'
    if (dart.library.html) './encryption_service_web.dart';

EncryptionService createEncryptionService() => createEncryptionServiceImpl();

