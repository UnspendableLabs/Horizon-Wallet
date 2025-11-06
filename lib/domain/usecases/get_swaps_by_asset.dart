import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/entities/atomic_swap/atomic_swap.dart";
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetSwapsByAssetParams {
  final HttpConfig httpConfig;
  final String asset;
  final String orderBy;
  final String order;

  const GetSwapsByAssetParams({
    required this.httpConfig,
    required this.asset,
    required this.orderBy,
    required this.order,
  });
}

class GetSwapsByAssetUseCase
    implements UseCaseTE<List<AtomicSwap>, GetSwapsByAssetParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;

  GetSwapsByAssetUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<AtomicSwap>> call(GetSwapsByAssetParams params) {
    final task = _atomicSwapRepository.getSwapsByAsset(
      httpConfig: params.httpConfig,
      asset: params.asset,
      orderBy: params.orderBy,
      order: params.order,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get swaps by asset",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "asset": params.asset,
                "orderBy": params.orderBy,
                "order": params.order,
              }
            : {
                "message": error?.toString(),
                "asset": params.asset,
                "orderBy": params.orderBy,
                "order": params.order,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
