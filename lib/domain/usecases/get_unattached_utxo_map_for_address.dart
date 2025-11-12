import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/utxo.dart";
import "package:horizon/domain/repositories/utxo_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetUnattachedUtxoMapForAddressParams {
  final String address;
  final HttpConfig httpConfig;

  const GetUnattachedUtxoMapForAddressParams({
    required this.address,
    required this.httpConfig,
  });
}

class GetUnattachedUtxoMapForAddressUseCase
    implements
        UseCaseTE<Map<String, Utxo>, GetUnattachedUtxoMapForAddressParams,
            String> {
  final UtxoRepository _utxoRepository;
  final ErrorService _errorService;

  GetUnattachedUtxoMapForAddressUseCase({
    UtxoRepository? utxoRepository,
    ErrorService? errorService,
  })  : _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, Map<String, Utxo>> call(
      GetUnattachedUtxoMapForAddressParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _utxoRepository.getUnattachedUTXOMapForAddress(
          params.address,
          params.httpConfig,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get unattached UTXO map for address",
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
