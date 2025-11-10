import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import "package:fpdart/fpdart.dart";

abstract class RoyaltiesRepository {
  TaskEither<NetworkError, RoyaltyByAsset?> getByAsset(
      {required String assetName, required HttpConfig httpConfig});
}
