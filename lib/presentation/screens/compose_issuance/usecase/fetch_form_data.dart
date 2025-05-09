import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/entities/http_clients.dart';

class FetchIssuanceFormDataUseCase {
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final HttpClients httpClients;

  FetchIssuanceFormDataUseCase({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.httpClients,
      
  });

  Future<(List<Balance>, FeeEstimates)> call(String currentAddress) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchBalances(currentAddress),
        _fetchFeeEstimates(),
      ]);

      final balances = futures[0] as List<Balance>;
      final feeEstimates = futures[1] as FeeEstimates;

      return (balances, feeEstimates);
    } on FetchBalancesException catch (e) {
      throw FetchBalancesException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Balance>> _fetchBalances(String currentAddress) async {
    try {
      final balances_ =
          await balanceRepository.getBalancesForAddress(
          client: httpClients.counterparty,
          address: currentAddress, excludeUtxoAttached: true);
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
