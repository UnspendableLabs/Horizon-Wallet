import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchCloseDispenserFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final DispenserRepository dispenserRepository;

  FetchCloseDispenserFormDataUseCase({
    required this.getFeeEstimatesUseCase,
    required this.dispenserRepository,
  });

  Future<(FeeEstimates, List<Dispenser>)> call(String currentAddress) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchDispenser(currentAddress),
        _fetchFeeEstimates(),
      ]);

      final dispensers = futures[0] as List<Dispenser>;
      final feeEstimates = futures[1] as FeeEstimates;

      return (feeEstimates, dispensers);
    } on FetchDispenserException catch (e) {
      throw FetchDispenserException(e.message);
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

  Future<List<Dispenser>> _fetchDispenser(String currentAddress) async {
    try {
      return await dispenserRepository
          .getDispensersByAddress(currentAddress)
          .run()
          .then((either) => either.fold(
                (error) => throw FetchDispenserException(
                    error.toString()), // Handle failure
                (dispensers) => dispensers, // Handle success
              ));
    } catch (e) {
      throw FetchDispenserException(e.toString());
    }
  }
}

class FetchDispenserException implements Exception {
  final String message;
  FetchDispenserException(this.message);

  @override
  String toString() => 'FetchDispenserException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
