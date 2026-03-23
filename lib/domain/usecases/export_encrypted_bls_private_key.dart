import 'dart:convert' show utf8;

import 'package:convert/convert.dart' as convert;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/seed_service.dart';

import "./usecase.dart";
export "./usecase.dart";

/// Parameters for [ExportEncryptedBlsPrivateKeyUseCase].
class ExportEncryptedBlsPrivateKeyParams {
  final WalletConfig walletConfig;
  final DecryptionStrategy decryptionStrategy;
  final String exportPassword;

  const ExportEncryptedBlsPrivateKeyParams({
    required this.walletConfig,
    required this.decryptionStrategy,
    required this.exportPassword,
  });
}

/// Derives the BLS master private key from the wallet seed, encrypts its hex
/// form with [exportPassword], then returns a hex-encoded UTF-8 display string.
///
/// Meaningful encryption is only available on web; on other platforms this use
/// case throws [UnsupportedError].
class ExportEncryptedBlsPrivateKeyUseCase
    implements UseCaseFuture<String, ExportEncryptedBlsPrivateKeyParams> {
  final SeedService _seedService;
  final BlsService _blsService;
  final EncryptionService _encryptionService;

  ExportEncryptedBlsPrivateKeyUseCase({
    SeedService? seedService,
    BlsService? blsService,
    EncryptionService? encryptionService,
  })  : _seedService = seedService ?? GetIt.I<SeedService>(),
        _blsService = blsService ?? GetIt.I<BlsService>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>();

  @override
  Future<String> call(ExportEncryptedBlsPrivateKeyParams params) async {
    if (!kIsWeb) {
      throw UnsupportedError(
        'Exporting an encrypted BLS private key is only supported on web.',
      );
    }

    final seed = await _seedService.getForWalletConfig(
      walletConfig: params.walletConfig,
      decryptionStrategy: params.decryptionStrategy,
    );

    final sk = _blsService.deriveMasterPrivateKey(seed.bytes);
    final hexSk = convert.hex.encode(sk);
    final encryptedString =
        await _encryptionService.encrypt(hexSk, params.exportPassword);
    return convert.hex.encode(utf8.encode(encryptedString));
  }
}
