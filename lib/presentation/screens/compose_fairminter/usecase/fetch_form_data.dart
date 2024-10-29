import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchFairminterFormDataUseCase {
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  FetchFairminterFormDataUseCase({
    required this.assetRepository,
    required this.getFeeEstimatesUseCase,
  });

  Future<(List<Asset>, FeeEstimates)> call(String currentAddress) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchAssets(currentAddress),
        _fetchFeeEstimates(),
      ]);

      final assets = futures[0] as List<Asset>;
      final feeEstimates = futures[1] as FeeEstimates;

      return (assets, feeEstimates);
    } on FetchAssetsException catch (e) {
      throw FetchAssetsException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Asset>> _fetchAssets(String currentAddress) async {
    try {
      final assets =
          await assetRepository.getValidAssetsByOwnerVerbose(currentAddress);
      return assets;
    } catch (e) {
      throw FetchAssetsException(e.toString());
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

class FetchAssetsException implements Exception {
  final String message;
  FetchAssetsException(this.message);

  @override
  String toString() => 'FetchAssetsException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
