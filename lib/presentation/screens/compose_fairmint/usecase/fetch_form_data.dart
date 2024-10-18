import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchComposeFairmintFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final FairminterRepository fairminterRepository;

  FetchComposeFairmintFormDataUseCase({
    required this.getFeeEstimatesUseCase,
    required this.fairminterRepository,
  });

  Future<(FeeEstimates, List<Fairminter>)> call() async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchFairminters(),
        _fetchFeeEstimates(),
      ]);

      final fairminters = futures[0] as List<Fairminter>;
      final feeEstimates = futures[1] as FeeEstimates;

      return (feeEstimates, fairminters);
    } on FetchFairmintersException catch (e) {
      throw FetchFairmintersException(e.message);
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

  Future<List<Fairminter>> _fetchFairminters() async {
    try {
      return await fairminterRepository
          .getAllFairminters()
          .run()
          .then((either) => either.fold(
                (error) => throw FetchFairmintersException(
                    error.toString()), // Handle failure
                (fairminters) => fairminters, // Handle success
              ));
    } catch (e) {
      throw FetchFairmintersException(e.toString());
    }
  }
}

class FetchFairmintersException implements Exception {
  final String message;
  FetchFairmintersException(this.message);

  @override
  String toString() => 'FetchFairmintersException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
