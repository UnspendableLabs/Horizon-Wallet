import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchComposeAttachUtxoFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final BalanceRepository balanceRepository;
  final EstimateXcpFeeRepository estimateXcpFeeRepository;

  FetchComposeAttachUtxoFormDataUseCase({
    required this.getFeeEstimatesUseCase,
    required this.balanceRepository,
    required this.estimateXcpFeeRepository,
  });

  Future<(FeeEstimates, List<Balance>, int)> call(String address) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchBalances(address),
        _fetchFeeEstimates(),
        _fetchAttachXcpFees(address),
      ]);

      final balances = futures[0] as List<Balance>;
      final feeEstimates = futures[1] as FeeEstimates;
      final attachXcpFees = futures[2] as int;

      return (feeEstimates, balances, attachXcpFees);
    } on FetchBalanceException catch (e) {
      throw FetchBalanceException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } on FetchAttachXcpFeesException catch (e) {
      throw FetchAttachXcpFeesException(e.message);
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

  Future<List<Balance>> _fetchBalances(String address) async {
    try {
      final balances =
          await balanceRepository.getBalancesForAddress(address, true);
      final nonBtcBalances =
          balances.where((balance) => balance.asset != 'BTC').toList();
      return nonBtcBalances;
    } catch (e) {
      throw FetchBalanceException(e.toString());
    }
  }

  Future<int> _fetchAttachXcpFees(String address) async {
    try {
      return await estimateXcpFeeRepository.estimateAttachXcpFees(address);
    } catch (e) {
      throw FetchAttachXcpFeesException(e.toString());
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

class FetchAttachXcpFeesException implements Exception {
  final String message;
  FetchAttachXcpFeesException(this.message);

  @override
  String toString() => 'FetchAttachXcpFeesException: $message';
}
