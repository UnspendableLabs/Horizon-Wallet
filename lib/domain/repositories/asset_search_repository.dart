import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class AssetSearchRepository {
  TaskEither<NetworkError, List<AssetSearchResult>> search(
      {required HttpConfig httpConfig,
      required String term,
      NetworkError? Function(NetworkError error)? onError});
}
