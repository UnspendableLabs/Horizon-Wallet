import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetUtxoSwapMapParams {
  final HttpConfig httpConfig;
  final List<String> addresses;

  const GetUtxoSwapMapParams({
    required this.httpConfig,
    required this.addresses,
  });
}

class GetUtxoSwapMapUseCase
    implements UseCaseTE<Map<String, bool>, GetUtxoSwapMapParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;

  GetUtxoSwapMapUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, Map<String, bool>> call(GetUtxoSwapMapParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        final futures = params.addresses.map((address) {
          return _atomicSwapRepository.getUtxoSwapMap(
            httpConfig: params.httpConfig,
            sellerAddress: address,
          );
        });

        final listOfMaps = await Future.wait(futures);
        return listOfMaps.fold<Map<String, bool>>(
          {},
          (acc, map) => {...acc, ...map},
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get UTXO swap map for addresses",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
