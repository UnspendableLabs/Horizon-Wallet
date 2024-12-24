import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchDispenseFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchDispenseFormDataUseCase({
    required this.getFeeEstimatesUseCase,
  });

  Future<FeeEstimates> call(String currentAddress) async {
    try {
      // Initiate both asynchronous calls
      return await _fetchFeeEstimates();
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call();
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
