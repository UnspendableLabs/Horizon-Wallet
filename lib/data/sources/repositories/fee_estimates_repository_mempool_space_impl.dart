import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/entities/http_config.dart";
import 'package:horizon/data/sources/network/mempool_space_client_factory.dart';

class FeeEstimatesRespositoryMempoolSpaceImpl
    implements FeeEstimatesRespository {
  final MempoolSpaceClientFactory _mempoolSpaceClientFactory;
  FeeEstimatesRespositoryMempoolSpaceImpl({
    required MempoolSpaceClientFactory mempoolSpaceClientFactory,
  }) : _mempoolSpaceClientFactory = mempoolSpaceClientFactory;

  @override
  Future<FeeEstimates> getFeeEstimates({required HttpConfig httpConfig}) async {
    final client = _mempoolSpaceClientFactory.getClient(httpConfig);
    final response = await client.getFeeEstimates();
    return FeeEstimates(
      fast: response.fastestFee,
      medium: response.halfHourFee,
      slow: response.hourFee,
    );
  }
}
