import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/entities/royalty_by_asset.dart";
import "package:horizon/domain/repositories/royalties_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetRoyaltyByAssetParams {
  final HttpConfig httpConfig;
  final String assetName;

  const GetRoyaltyByAssetParams({
    required this.httpConfig,
    required this.assetName,
  });
}

class GetRoyaltyByAssetUseCase
    implements
        UseCaseTE<Option<RoyaltyByAsset>, GetRoyaltyByAssetParams, String> {
  final RoyaltiesRepository _royaltiesRepository;
  final ErrorService _errorService;

  GetRoyaltyByAssetUseCase({
    RoyaltiesRepository? royaltiesRepository,
    ErrorService? errorService,
  })  : _royaltiesRepository =
            royaltiesRepository ?? GetIt.I<RoyaltiesRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, Option<RoyaltyByAsset>> call(
      GetRoyaltyByAssetParams params) {
    final task = _royaltiesRepository.getByAsset(
      assetName: params.assetName,
      httpConfig: params.httpConfig,
    );

    return task
        .tapError((error) {
          _errorService.captureException(
            error,
            message: "Failed to get royalty by asset",
            context: error is NetworkError
                ? {
                    "message": error.message,
                    "endpoint": error.endpoint,
                    "fullUrl": error.fullUrl,
                    "statusCode": error.statusCode,
                    "assetName": params.assetName,
                  }
                : {
                    "message": error?.toString(),
                    "assetName": params.assetName,
                  },
          );
        })
        .mapLeft((error) => error.message)
        .map(Option.fromNullable);
  }
}
