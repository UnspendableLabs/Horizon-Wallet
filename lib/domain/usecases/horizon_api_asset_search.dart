import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/asset_search_result.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/asset_search_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class SearchAssetsParams {
  final HttpConfig httpConfig;
  final String term;

  const SearchAssetsParams({
    required this.httpConfig,
    required this.term,
  });
}

class SearchAssetsUseCase
    implements UseCaseTE<List<AssetSearchResult>, SearchAssetsParams, String> {
  final AssetSearchRepository _assetSearchRepository;
  final ErrorService _errorService;

  SearchAssetsUseCase({
    AssetSearchRepository? assetSearchRepository,
    ErrorService? errorService,
  })  : _assetSearchRepository =
            assetSearchRepository ?? GetIt.I<AssetSearchRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<AssetSearchResult>> call(SearchAssetsParams params) {
    final task = _assetSearchRepository.search(
      httpConfig: params.httpConfig,
      term: params.term,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to search assets with term: ${params.term}",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
              }
            : {
                "message": error.toString(),
              },
      );
    }).mapLeft((error) => error.message);
  }
}
