import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/services/bitcoind_service.dart";

class GetFeeEstimatesUseCase {
  final BitcoindService bitcoindService;

  const GetFeeEstimatesUseCase({required this.bitcoindService});

  Future<FeeEstimates> call({required (int, int, int) targets}) async {
    final (fastTarget, mediumTarget, slowTarget) = targets;

    final results = await Future.wait([
      bitcoindService.estimateSmartFee(confirmationTarget: fastTarget),
      bitcoindService.estimateSmartFee(confirmationTarget: mediumTarget),
      bitcoindService.estimateSmartFee(confirmationTarget: slowTarget),
    ]);

    // kbytes to bytes
    return FeeEstimates(
      fast: (results[0] / 1000).ceil(),
      medium: (results[1] / 1000).ceil(),
      slow: (results[2] / 1000).ceil(),
    );
  }
}
