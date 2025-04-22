import "package:horizon/domain/entities/fee_estimates.dart";
import "package:fpdart/fpdart.dart";

abstract class FeeEstimatesRespository {
  TaskEither<String, FeeEstimates> getFeeEstimatesTask();
  Future<FeeEstimates> getFeeEstimates();
}
