import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/network_error.dart';
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
  TaskEither<NetworkError, RoyaltyByAsset?> getByAsset(
      {required HttpConfig httpConfig, required String assetName}) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.getRoyaltyByAsset(assetName: assetName);

      return res.data?.toEntity();
    });
  }
}
