import "package:horizon/domain/entities/fee_estimates.dart";
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';

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

extension GetFeeEstimatesUseCaseX on GetFeeEstimatesUseCase {
  TaskEither<String, FeeEstimates> callT({
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => call(httpConfig: httpConfig),
      (e, _) => onError(e),
    );
  }
}
