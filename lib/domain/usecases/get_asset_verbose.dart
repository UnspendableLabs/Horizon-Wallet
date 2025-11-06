import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/asset_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetAssetVerboseParams {
  final HttpConfig httpConfig;
  final String assetName;

  const GetAssetVerboseParams({
    required this.httpConfig,
    required this.assetName,
  });
}

class GetAssetVerboseUseCase
    implements UseCaseTE<Asset, GetAssetVerboseParams, String> {
  final AssetRepository _assetRepository;
  final ErrorService _errorService;

  GetAssetVerboseUseCase({
    AssetRepository? assetRepository,
    ErrorService? errorService,
  })  : _assetRepository = assetRepository ?? GetIt.I<AssetRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, Asset> call(GetAssetVerboseParams params) {
    final task = _assetRepository.getAssetVerbose(
      assetName: params.assetName,
      httpConfig: params.httpConfig,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get asset verbose: ${params.assetName}",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "assetName": params.assetName,
              }
            : {
                "message": error.toString(),
                "assetName": params.assetName,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
