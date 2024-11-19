import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchComposeAttachUtxoFormDataUseCase {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final AssetRepository assetRepository;

  FetchComposeAttachUtxoFormDataUseCase({
    required this.getFeeEstimatesUseCase,
    required this.assetRepository,
  });

  Future<(FeeEstimates, Asset)> call(String assetName) async {
    print('IN THE USECASE');
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchAsset(assetName),
        _fetchFeeEstimates(),
      ]);

      print('fetched futures: ${futures[0]} ${futures[1]}');
      final asset = futures[0] as Asset;
      final feeEstimates = futures[1] as FeeEstimates;

      return (feeEstimates, asset);
    } on FetchAssetException catch (e) {
      throw FetchAssetException(e.message);
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

  Future<Asset> _fetchAsset(String assetName) async {
    try {
      return await assetRepository.getAssetVerbose(assetName);
    } catch (e) {
      throw FetchAssetException(e.toString());
    }
  }
}

class FetchAssetException implements Exception {
  final String message;
  FetchAssetException(this.message);

  @override
  String toString() => 'FetchAssetException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
