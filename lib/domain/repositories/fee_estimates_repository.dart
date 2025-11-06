import "package:horizon/domain/entities/fee_estimates.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';
import "package:horizon/domain/entities/network_error.dart";

abstract class FeeEstimatesRespository {
  TaskEither<NetworkError, FeeEstimates> getFeeEstimates({
    required HttpConfig httpConfig,
  });
}
