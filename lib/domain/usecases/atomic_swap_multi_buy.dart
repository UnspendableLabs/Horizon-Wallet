import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/atomic_swap/atomic_swap_buy.dart";
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import "package:horizon/domain/services/analytics_service.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class AtomicSwapMultiBuyParams {
  final HttpConfig httpConfig;
  final List<String> ids;
  final String psbtHex;
  final String buyerAddress;

  const AtomicSwapMultiBuyParams({
    required this.httpConfig,
    required this.ids,
    required this.psbtHex,
    required this.buyerAddress,
  });
}

class AtomicSwapMultiBuyUseCase
    implements
        UseCaseTE<List<AtomicSwapBuy>, AtomicSwapMultiBuyParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;
  final AnalyticsService _analyticsService;

  AtomicSwapMultiBuyUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
    AnalyticsService? analyticsService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>(),
        _analyticsService = analyticsService ?? GetIt.I<AnalyticsService>();

  @override
  TaskEither<String, List<AtomicSwapBuy>> call(
      AtomicSwapMultiBuyParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _atomicSwapRepository.atomicSwapMultiBuy(
          httpConfig: params.httpConfig,
          ids: params.ids,
          psbtHex: params.psbtHex,
          buyerAddress: params.buyerAddress,
        );
      },
      maxRetries: maxRetries,
    ).tap((success) {
      _analyticsService.trackAnonymousEvent("atomic_swap_listing(s)_purchased");
    }).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to execute atomic swap multi-buy",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "ids": params.ids,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
