import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/entities/http_config.dart';

class FetchDispenserFormDataUseCase {
  final BalanceRepository balanceRepository;
  final DispenserRepository dispenserRepository;

  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchDispenserFormDataUseCase({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.dispenserRepository,
  });

  Future<(List<Balance>, FeeEstimates, List<Dispenser>)> call(
      String currentAddress, HttpConfig httpConfig) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchBalances(currentAddress, httpConfig),
        _fetchFeeEstimates(),
        _fetchDispensers(currentAddress),
      ]);

      final balances = futures[0] as List<Balance>;
      final feeEstimates = futures[1] as FeeEstimates;
      final dispenser = futures[2] as List<Dispenser>;

      return (balances, feeEstimates, dispenser);
    } on FetchBalancesException catch (e) {
      throw FetchBalancesException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } on FetchDispenserException catch (e) {
      throw FetchDispenserException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Balance>> _fetchBalances(
      String currentAddress, HttpConfig httpConfig) async {
    try {
      final balances_ = await balanceRepository.getBalancesForAddress(
          httpConfig: httpConfig,
          address: currentAddress,
          excludeUtxoAttached: true);
      return balances_.where((balance) => balance.asset != 'BTC').toList();
    } catch (e) {
      throw FetchBalancesException(e.toString());
    }
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call();
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  Future<List<Dispenser>> _fetchDispensers(String currentAddress) async {
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

class FetchBalancesException implements Exception {
  final String message;
  FetchBalancesException(this.message);

  @override
  String toString() => 'FetchBalancesException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}

class FetchDispenserException implements Exception {
  final String message;
  FetchDispenserException(this.message);

  @override
  String toString() => 'FetchDispenserException: $message';
}
