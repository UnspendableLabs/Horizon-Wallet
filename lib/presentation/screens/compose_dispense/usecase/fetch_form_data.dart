import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/entities/http_config.dart';

class FetchDispenseFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchDispenseFormDataUseCase({
    required this.getFeeEstimatesUseCase,
  });

  Future<FeeEstimates> call(
      String currentAddress, HttpConfig httpConfig) async {
    try {
      // Initiate both asynchronous calls
      return await _fetchFeeEstimates(httpConfig);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<FeeEstimates> _fetchFeeEstimates(HttpConfig httpConfig) async {
    try {
      return await getFeeEstimatesUseCase.call(httpConfig: httpConfig);
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
