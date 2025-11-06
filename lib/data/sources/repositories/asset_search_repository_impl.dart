import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';

class AssetSearchRepositoryImpl implements AssetSearchRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;

  AssetSearchRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  TaskEither<NetworkError, List<AssetSearchResult>> search(
      {required HttpConfig httpConfig,
      required String term,
      NetworkError? Function(NetworkError error)? onError}) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = client.searchAssets(query: term);

      return res;
    }, onError: onError);
  }
}
