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

class SearchSwapsParams {
  final HttpConfig httpConfig;
  final String search;
  final String orderBy;
  final String order;

  const SearchSwapsParams({
    required this.httpConfig,
    required this.search,
    this.orderBy = "price",
    this.order = "asc",
  });
}

class SearchSwapsUseCase
    implements UseCaseTE<List<AtomicSwap>, SearchSwapsParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;

  SearchSwapsUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<AtomicSwap>> call(SearchSwapsParams params) {
    final task = _atomicSwapRepository.searchSwaps(
      httpConfig: params.httpConfig,
      search: params.search,
      orderBy: params.orderBy,
      order: params.order,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to search swaps",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "search": params.search,
                "orderBy": params.orderBy,
                "order": params.order,
              }
            : {
                "message": error?.toString(),
                "search": params.search,
                "orderBy": params.orderBy,
                "order": params.order,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
