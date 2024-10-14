import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
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

  Future<(FeeEstimates, List<Dispenser>)> call(Address currentAddress) async {
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
      return await getFeeEstimatesUseCase.call(targets: (1, 3, 6));
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  Future<List<Dispenser>> _fetchDispenser(Address currentAddress) async {
    try {
      return await dispenserRepository.getDispenserByAddress(currentAddress.address);
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
