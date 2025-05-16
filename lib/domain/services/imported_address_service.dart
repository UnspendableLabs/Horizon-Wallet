import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/network.dart';

abstract class ImportedAddressService {
  Future<String> getAddressPrivateKeyFromWIF({
    required String wif,
    required Network network,
  });
  Future<String> getAddressFromWIF({
    required String wif,
    required ImportAddressPkFormat format,
    required Network network,
  });
}

extension ImportedAddressServiceX on ImportedAddressService {
  TaskEither<E, String> getAddressPrivateKeyFromWIFT<E>({
    required String wif,
    required Network network,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getAddressPrivateKeyFromWIF(wif: wif, network: network),
      onError,
    );
  }

  TaskEither<E, String> getAddressFromWIFT<E>({
    required String wif,
    required ImportAddressPkFormat format,
    required Network network,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getAddressFromWIF(wif: wif, format: format, network: network),
      onError,
    );
  }
}
