import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/entities/http_clients.dart';

class FetchDividendFormDataUseCase {
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final AssetRepository assetRepository;
  final EstimateXcpFeeRepository estimateXcpFeeRepository;
  final HttpClients httpClients;

  FetchDividendFormDataUseCase({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.assetRepository,
    required this.estimateXcpFeeRepository,
    required this.httpClients,
  });

  Future<(List<Balance>, Asset, FeeEstimates, int)> call(
      String currentAddress, String assetName) async {
    try {
      final futures = await Future.wait([
        _fetchBalances(currentAddress),
        _fetchAsset(assetName),
        _fetchFeeEstimates(),
        _fetchDividendXcpFee(currentAddress, assetName),
      ]);

      final balances = futures[0] as List<Balance>;
      final asset = futures[1] as Asset;
      final feeEstimates = futures[2] as FeeEstimates;
      final dividendXcpFee = futures[3] as int;

      return (balances, asset, feeEstimates, dividendXcpFee);
    } on FetchAssetException catch (e) {
      throw FetchAssetException(e.message);
    } on FetchBalancesException catch (e) {
      throw FetchBalancesException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } on FetchDividendXcpFeeException catch (e) {
      throw FetchDividendXcpFeeException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Balance>> _fetchBalances(String currentAddress) async {
    try {
      final balances_ = await balanceRepository.getBalancesForAddress(
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

  Future<Asset> _fetchAsset(String assetName) async {
    try {
      return await assetRepository.getAssetVerbose(assetName);
    } catch (e) {
      throw FetchAssetException(e.toString());
    }
  }

  Future<int> _fetchDividendXcpFee(
      String currentAddress, String assetName) async {
    try {
      return await estimateXcpFeeRepository.estimateDividendXcpFees(
          currentAddress, assetName);
    } catch (e) {
      throw FetchDividendXcpFeeException(e.toString());
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

class FetchAssetException implements Exception {
  final String message;
  FetchAssetException(this.message);

  @override
  String toString() => 'FetchAssetException: $message';
}

class FetchDividendXcpFeeException implements Exception {
  final String message;
  FetchDividendXcpFeeException(this.message);

  @override
  String toString() => 'FetchDividendXcpFeeException: $message';
}
