import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchComposeDetachUtxoFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchComposeDetachUtxoFormDataUseCase({
    required this.getFeeEstimatesUseCase,
  });

  Future<FeeEstimates> call() async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchFeeEstimates(),
      ]);

      final feeEstimates = futures[0];

      return feeEstimates;
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call(targets: (1, 3, 6));
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
