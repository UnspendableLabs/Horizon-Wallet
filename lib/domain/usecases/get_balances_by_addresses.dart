import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/common/constants.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/multi_address_balance.dart";
import "package:horizon/domain/repositories/balance_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetBalancesByAddressesParams {
  final HttpConfig httpConfig;
  final List<String> addresses;
  final BalanceType? type;

  const GetBalancesByAddressesParams({
    required this.httpConfig,
    required this.addresses,
    this.type,
  });
}

class GetBalancesByAddressesUseCase
    implements
        UseCaseTE<List<MultiAddressBalance>, GetBalancesByAddressesParams,
            String> {
  final BalanceRepository _balanceRepository;
  final ErrorService _errorService;

  GetBalancesByAddressesUseCase({
    BalanceRepository? balanceRepository,
    ErrorService? errorService,
  })  : _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<MultiAddressBalance>> call(
      GetBalancesByAddressesParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _balanceRepository.getBalancesForAddresses(
          httpConfig: params.httpConfig,
          addresses: params.addresses,
          type: params.type,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get balances by addresses",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "addresses": params.addresses,
          "type": params.type?.name,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
