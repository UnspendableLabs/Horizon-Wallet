// data/services/wallet_service_factory.dart

import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

import 'wallet_service_stub.dart'
    if (dart.library.io) 'wallet_service_native.dart'
    if (dart.library.html) 'wallet_service_web.dart';

WalletService createWalletService({
  required EncryptionService encryptionService,
  required Config config,
}) =>
    createWalletServiceImpl(
        encryptionService: encryptionService, config: config);
