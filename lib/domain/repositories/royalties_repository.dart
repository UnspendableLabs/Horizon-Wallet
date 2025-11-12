import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';

abstract class RoyaltiesRepository {
  Future<RoyaltyByAsset?> getByAsset(
      {required String assetName, required HttpConfig httpConfig});
}
