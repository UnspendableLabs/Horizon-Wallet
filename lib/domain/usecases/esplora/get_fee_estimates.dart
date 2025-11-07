import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "../usecase.dart";
export "../usecase.dart";

class GetFeeEstimatesEsploraParams {
  final HttpConfig httpConfig;

  const GetFeeEstimatesEsploraParams({
    required this.httpConfig,
  });
}

class GetFeeEstimatesEsploraUseCase
    implements UseCaseTE<Map<String, double>, GetFeeEstimatesEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetFeeEstimatesEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, Map<String, double>> call(GetFeeEstimatesEsploraParams params) {
    final task = _bitcoinRepository.getFeeEstimates(
      httpConfig: params.httpConfig,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get fee estimates",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
              }
            : {
                "message": error?.toString(),
              },
      );
    }).mapLeft((error) => error.message);
  }
}

