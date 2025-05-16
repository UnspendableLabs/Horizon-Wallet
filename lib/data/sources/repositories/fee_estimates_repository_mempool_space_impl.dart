import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/entities/network.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/data/sources/network/mempool_space_client.dart';

class FeeEstimatesRespositoryMempoolSpaceImpl
    implements FeeEstimatesRespository {
  final MempoolSpaceApi _mempoolSpaceApi;

  FeeEstimatesRespositoryMempoolSpaceImpl(
      {required MempoolSpaceApi mempoolSpaceApi})
      : _mempoolSpaceApi = mempoolSpaceApi;

  @override
  TaskEither<String, FeeEstimates> getFeeEstimates(
      {required HttpConfig httpConfig}) {
    return TaskEither.tryCatch(
      () => _getFeeEstimates(network: httpConfig.network),
      (error, stacktrace) => "GetFeeEstimates failure",
    );
  }

  Future<FeeEstimates> _getFeeEstimates({required Network network}) async {
    final response = await _mempoolSpaceApi.getFeeEstimates(network: network);

    return FeeEstimates(
      fast: response.fastestFee,
      medium: response.halfHourFee,
      slow: response.hourFee,
    );
  }
}
