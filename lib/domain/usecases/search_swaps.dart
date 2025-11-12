import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
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
  TaskEither<String, List<AtomicSwap>> call(SearchSwapsParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _atomicSwapRepository.searchSwaps(
          httpConfig: params.httpConfig,
          search: params.search,
          orderBy: params.orderBy,
          order: params.order,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to search swaps",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "search": params.search,
          "orderBy": params.orderBy,
          "order": params.order,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
