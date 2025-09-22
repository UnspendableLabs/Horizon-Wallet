import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/royalties_repository.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';

class RoyaltiesRepositoryImpl implements RoyaltiesRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;

  RoyaltiesRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  Future<RoyaltyByAsset?> getByAsset(
      {required HttpConfig httpConfig, required String assetName}) async {
    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = await client.getRoyaltyByAsset(assetName: assetName);

    return res.data?.toEntity();
  }
}
