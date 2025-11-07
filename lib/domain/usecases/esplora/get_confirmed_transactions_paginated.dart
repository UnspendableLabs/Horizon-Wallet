import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "../usecase.dart";
export "../usecase.dart";

class GetConfirmedTransactionsPaginateParams {
  final HttpConfig httpConfig;
  final String address;
  final String? lastSeenTxid;

  const GetConfirmedTransactionsPaginateParams({
    required this.httpConfig,
    required this.address,
    this.lastSeenTxid,
  });
}

class GetConfirmedTransactionsPaginatedUseCase
    implements
        UseCaseTE<List<BitcoinTx>, GetConfirmedTransactionsPaginateParams,
            String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetConfirmedTransactionsPaginatedUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<BitcoinTx>> call(
      GetConfirmedTransactionsPaginateParams params) {
    final task = _bitcoinRepository.getConfirmedTransactionsPaginated(
      httpConfig: params.httpConfig,
      address: params.address,
      lastSeenTxid: params.lastSeenTxid,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get confirmed transactions paginated",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "address": params.address,
                "lastSeenTxid": params.lastSeenTxid,
              }
            : {
                "message": error?.toString(),
                "address": params.address,
                "lastSeenTxid": params.lastSeenTxid,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
