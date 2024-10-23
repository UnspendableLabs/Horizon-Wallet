import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "package:horizon/domain/entities/fee_estimates.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/data/sources/network/mempool_space_client.dart';

class FeeEstimatesRespositoryMempoolSpaceImpl
    implements FeeEstimatesRespository {
  final MempoolSpaceApi _mempoolSpaceApi;

  FeeEstimatesRespositoryMempoolSpaceImpl(
      {required MempoolSpaceApi mempoolSpaceApi})
      : _mempoolSpaceApi = mempoolSpaceApi;

  @override
  TaskEither<String, FeeEstimates> getFeeEstimates() {
    return TaskEither.tryCatch(
      _getFeeEstimates,
      (error, stacktrace) => "GetFeeEstimates failure",
    );
  }

  Future<FeeEstimates> _getFeeEstimates() async {
    final response = await _mempoolSpaceApi.getFeeEstimates();

    return FeeEstimates(
      fast: response.fastestFee,
      medium: response.halfHourFee,
      slow: response.hourFee,
    );
  }
}
