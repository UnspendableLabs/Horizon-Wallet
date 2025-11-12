import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/address_info.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "../usecase.dart";
export "../usecase.dart";

class GetAddressInfoEsploraParams {
  final HttpConfig httpConfig;
  final String address;

  const GetAddressInfoEsploraParams({
    required this.httpConfig,
    required this.address,
  });
}

class GetAddressInfoEsploraUseCase
    implements UseCaseTE<AddressInfo, GetAddressInfoEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetAddressInfoEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, AddressInfo> call(GetAddressInfoEsploraParams params) {
    final task = handleNetworkCall(() async {
      return await _bitcoinRepository.getAddressInfo(
        httpConfig: params.httpConfig,
        address: params.address,
      );
    });

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get address info",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "address": params.address,
        },
      );
    }).mapLeft((error) => error.message);
  }
}

class GetAddressInfoMultiEsploraParams {
  final HttpConfig httpConfig;
  final List<String> addresses;

  const GetAddressInfoMultiEsploraParams({
    required this.httpConfig,
    required this.addresses,
  });
}

class GetAddressInfoMultiEsploraUseCase
    implements
        UseCaseTE<List<AddressInfo>, GetAddressInfoMultiEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetAddressInfoMultiEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<AddressInfo>> call(
      GetAddressInfoMultiEsploraParams params) {
    return TaskEither.sequenceList(params.addresses
        .map((address) => handleNetworkCall(() async {
              return await _bitcoinRepository.getAddressInfo(
                  address: address, httpConfig: params.httpConfig);
            }).tapError((e) {
              _errorService.captureException(e,
                  message: "Failed to get address info",
                  context: {
                    "message": e.message,
                    "endpoint": e.endpoint,
                    "fullUrl": e.fullUrl,
                    "statusCode": e.statusCode,
                    "address": address,
                  });
            }).mapLeft((e) => e.message))
        .toList());
  }
}
