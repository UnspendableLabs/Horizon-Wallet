import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class FetchFairminterFormDataUseCase {
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final FairminterRepository fairminterRepository;

  FetchFairminterFormDataUseCase({
    required this.assetRepository,
    required this.getFeeEstimatesUseCase,
    required this.fairminterRepository,
  });

  Future<(List<Asset>, FeeEstimates, List<Fairminter>)> call(
      String currentAddress) async {
    try {
      // Initiate both asynchronous calls
      final futures = await Future.wait([
        _fetchAssets(currentAddress),
        _fetchFeeEstimates(),
        _fetchFairminters(currentAddress),
      ]);

      final assets = futures[0] as List<Asset>;
      final feeEstimates = futures[1] as FeeEstimates;
      final fairminters = futures[2] as List<Fairminter>;
      return (assets, feeEstimates, fairminters);
    } on FetchAssetsException catch (e) {
      throw FetchAssetsException(e.message);
    } on FetchFeeEstimatesException catch (e) {
      throw FetchFeeEstimatesException(e.message);
    } on FetchFairmintersException catch (e) {
      throw FetchFairmintersException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Asset>> _fetchAssets(String currentAddress) async {
    try {
      final assets =
          await assetRepository.getAllValidAssetsByOwnerVerbose(currentAddress);
      return assets;
    } catch (e) {
      throw FetchAssetsException(e.toString());
    }
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call();
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  Future<List<Fairminter>> _fetchFairminters(String currentAddress) async {
    try {
      return await fairminterRepository
          .getFairmintersByAddress(currentAddress)
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

class FetchFairmintersException implements Exception {
  final String message;
  FetchFairmintersException(this.message);

  @override
  String toString() => 'FetchFairmintersException: $message';
}
