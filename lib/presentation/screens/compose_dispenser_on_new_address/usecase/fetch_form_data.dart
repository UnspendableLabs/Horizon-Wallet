import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchDispenserOnNewAddressFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchDispenserOnNewAddressFormDataUseCase({
    required this.getFeeEstimatesUseCase,
  });

  Future<FeeEstimates> call() async {
    try {
      final feeEstimates = await _fetchFeeEstimates();

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
