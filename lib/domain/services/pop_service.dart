import 'dart:typed_data';
import 'package:horizon/domain/repositories/config_repository.dart';

abstract class PopService {
  ({
    String xpubkey,
    String blsPubkey,
    String schnorrSig,
    String blsSig,
  }) generatePoP({
    required Uint8List seed,
    required String taprootDerivationPath,
    required Network network,
    required int accountIndex,
  });
}
