import "package:fpdart/fpdart.dart";
import "package:horizon/domain/entities/fairminter.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class FairminterRepository {
  TaskEither<String, List<Fairminter>> getAllFairminters(HttpConfig httpConfig);
  TaskEither<String, List<Fairminter>> getFairmintersByAddress(
      HttpConfig httpConfig, String address,
      [String? status]);
  TaskEither<String, List<Fairminter>> getFairmintersByAsset(
      HttpConfig httpConfig, String asset,
      [String? status]);
}
