import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/compose_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetDetachDataParams {
  final HttpConfig httpConfig;
  final String destination;

  const GetDetachDataParams({
    required this.httpConfig,
    required this.destination,
  });
}

class GetDetachDataUseCase
    implements UseCaseTE<String, GetDetachDataParams, String> {
  final ComposeRepository _composeRepository;
  final ErrorService _errorService;

  GetDetachDataUseCase({
    ComposeRepository? composeRepository,
    ErrorService? errorService,
  })  : _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, String> call(GetDetachDataParams params) {
    final task = _composeRepository.getDetachData(
      httpConfig: params.httpConfig,
      destination: params.destination,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get detach data",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "destination": params.destination,
              }
            : {
                "message": error?.toString(),
                "destination": params.destination,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
