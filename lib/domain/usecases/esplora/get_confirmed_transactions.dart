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

class GetConfirmedTransactionsEsploraParams {
  final HttpConfig httpConfig;
  final List<String> addresses;

  const GetConfirmedTransactionsEsploraParams({
    required this.httpConfig,
    required this.addresses,
  });
}

class GetConfirmedTransactionsEsploraUseCase
    implements
        UseCaseTE<List<BitcoinTx>, GetConfirmedTransactionsEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetConfirmedTransactionsEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<BitcoinTx>> call(
      GetConfirmedTransactionsEsploraParams params) {
    final task = _bitcoinRepository.getConfirmedTransactions(
      httpConfig: params.httpConfig,
      addresses: params.addresses,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get confirmed transactions",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "addresses": params.addresses,
              }
            : {
                "message": error?.toString(),
                "addresses": params.addresses,
              },
      );
    }).mapLeft((error) => error.message);
  }
}

