import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetFeeEstimatesParams {
  final HttpConfig httpConfig;

  const GetFeeEstimatesParams({
    required this.httpConfig,
  });
}

class GetFeeEstimatesUseCase
    implements UseCaseTE<FeeEstimates, GetFeeEstimatesParams, String> {
  final FeeEstimatesRespository _feeEstimatesRepository;
  final ErrorService _errorService;

  GetFeeEstimatesUseCase({
    FeeEstimatesRespository? feeEstimatesRepository,
    ErrorService? errorService,
  })  : _feeEstimatesRepository =
            feeEstimatesRepository ?? GetIt.I<FeeEstimatesRespository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, FeeEstimates> call(GetFeeEstimatesParams params) {
    final task = _feeEstimatesRepository.getFeeEstimates(
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
    }).mapLeft((_) => "Failed to get fee estimates");
  }
}
