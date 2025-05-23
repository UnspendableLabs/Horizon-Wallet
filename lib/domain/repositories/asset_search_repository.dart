import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class AssetSearchRepository {
  Future<List<AssetSearchResult>> search(
      {required HttpConfig httpConfig, required String term});
}

extension AssetSearchRepositoryX on AssetSearchRepository {
  TaskEither<E, List<AssetSearchResult>> searchT<E>({
    required HttpConfig httpConfig,
    required String term,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => search(httpConfig: httpConfig, term: term),
      onError,
    );
  }
}
