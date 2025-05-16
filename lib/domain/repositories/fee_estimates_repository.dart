import "package:horizon/domain/entities/fee_estimates.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class FeeEstimatesRespository {
  TaskEither<String, FeeEstimates> getFeeEstimates({
    required HttpConfig httpConfig,
  });
}
