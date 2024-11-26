import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchComposeMoveToUtxoFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final BalanceRepository balanceRepository;

  FetchComposeMoveToUtxoFormDataUseCase({
    required this.getFeeEstimatesUseCase,
    required this.balanceRepository,
  });

  Future<(FeeEstimates, Balance)> call(String utxo) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchBalanceForUtxo(utxo),
        _fetchFeeEstimates(),
      ]);

      final balance = futures[0] as Balance;
      final feeEstimates = futures[1] as FeeEstimates;

      return (feeEstimates, balance);
    } on FetchBalanceException catch (e) {
      throw FetchBalanceException(e.message);
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

  Future<Balance> _fetchBalanceForUtxo(String utxo) async {
    try {
      final balances = await balanceRepository.getBalancesForUTXO(utxo);
      // if (balances.isEmpty) {
      //   throw FetchBalanceException('No balance found for UTXO: $utxo');
      // }
      // final balanceForUtxo =
      //     balances.where((balance) => balance.utxo == utxo).toList();
      // if (balanceForUtxo.length > 1) {
      //   throw FetchBalanceException('Multiple balances found for UTXO: $utxo');
      // }
      return balances.first;
    } catch (e) {
      throw FetchBalanceException(e.toString());
    }
  }
}

class FetchBalanceException implements Exception {
  final String message;
  FetchBalanceException(this.message);

  @override
  String toString() => 'FetchBalanceException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
