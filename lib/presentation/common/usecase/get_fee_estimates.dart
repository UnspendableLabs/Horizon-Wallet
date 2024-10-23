import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/repositories/fee_estimates_repository.dart";

class GetFeeEstimatesUseCase {
  final FeeEstimatesRespository feeEstimatesRepository;

  const GetFeeEstimatesUseCase({
    required this.feeEstimatesRepository,
  });

  Future<FeeEstimates> call({required (int, int, int) targets}) async {
    return feeEstimatesRepository.getFeeEstimates().run().then(
          (either) => either.fold(
            (error) => throw Exception("GetFeeEstimates failure"),
            (feeEstimates) => feeEstimates,
          ),
        );
  }
}
