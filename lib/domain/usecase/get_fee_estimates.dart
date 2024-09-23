import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/services/bitcoind_service.dart";

class GetFeeEstimates {
  final (int, int, int) targets;
  final BitcoindService bitcoindService;

  const GetFeeEstimates({required this.targets, required this.bitcoindService});

  Future<FeeEstimates> call() async {
    final (fastTarget, mediumTarget, slowTarget) = targets;

    final results = await Future.wait([
      bitcoindService.estimateSmartFee(confirmationTarget: fastTarget),
      bitcoindService.estimateSmartFee(confirmationTarget: mediumTarget),
      bitcoindService.estimateSmartFee(confirmationTarget: slowTarget),
    ]);

    // kbytes to bytes
    return FeeEstimates(
      fast: results[0] ~/ 1000,
      medium: results[1] ~/ 1000,
      slow: results[2] ~/ 1000 ,
    );
  }
}
