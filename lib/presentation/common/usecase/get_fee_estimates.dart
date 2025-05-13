import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/domain/entities/http_config.dart';

class GetFeeEstimatesUseCase {
  final FeeEstimatesRespository feeEstimatesRepository;

  const GetFeeEstimatesUseCase({
    required this.feeEstimatesRepository,
  });

  Future<FeeEstimates> call({
    required HttpConfig httpConfig,
  }) async {
    return feeEstimatesRepository
        .getFeeEstimates(httpConfig: httpConfig)
        .run()
        .then(
          (either) => either.fold(
            (error) => throw Exception("GetFeeEstimates failure"),
            (feeEstimates) => feeEstimates,
          ),
        );
  }
}
