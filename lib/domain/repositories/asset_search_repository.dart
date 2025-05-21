
import 'package:fpdart/fpdart.dart';

class AssetSearchResult {
  final String name;

  const AssetSearchResult({required this.name});
}

abstract class AssetSearchRepository {
  Future<List<AssetSearchResult>> search({required String term});
}


extension AssetSearchRepositoryX on AssetSearchRepository {
  TaskEither<E, List<AssetSearchResult>> searchT<E>({
    required String term,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => search(term: term),
      onError,
    );
  }
}
