import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';

class AssetSearchRepositoryImpl implements AssetSearchRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;

  AssetSearchRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  Future<List<AssetSearchResult>> search(
      {required HttpConfig httpConfig, required String term}) async {
// {"data":["XCP","A10748947519108282879","A2977114591417842298","A7644917367163002844","A9571979917063295926"]}

    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = client.searchAssets(query: term);

    return res;
  }
}
