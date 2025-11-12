import "package:horizon/domain/entities/fee_estimates.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class FeeEstimatesRespository {
  Future<FeeEstimates> getFeeEstimates({
    required HttpConfig httpConfig,
  });
}
