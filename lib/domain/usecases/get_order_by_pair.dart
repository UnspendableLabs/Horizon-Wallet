import "package:fpdart/fpdart.dart" hide Order;
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/entities/order.dart";
import "package:horizon/domain/repositories/order_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetOrderByPairParams {
  final HttpConfig httpConfig;
  final String giveAsset;
  final String getAsset;
  final String? status;
  final String? sort;

  const GetOrderByPairParams({
    required this.httpConfig,
    required this.giveAsset,
    required this.getAsset,
    this.status,
    this.sort,
  });
}

class GetOrderByPairUseCase
    implements UseCaseTE<List<Order>, GetOrderByPairParams, String> {
  final OrderRepository _orderRepository;
  final ErrorService _errorService;

  GetOrderByPairUseCase({
    OrderRepository? orderRepository,
    ErrorService? errorService,
  })  : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<Order>> call(GetOrderByPairParams params) {
    final task = handleNetworkCall(() async {
      return await _orderRepository.getByPair(
        giveAsset: params.giveAsset,
        getAsset: params.getAsset,
        status: params.status,
        sort: params.sort,
        httpConfig: params.httpConfig,
      );
    });

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get orders by pair",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "giveAsset": params.giveAsset,
          "getAsset": params.getAsset,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
