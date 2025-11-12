import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "../usecase.dart";
export "../usecase.dart";

class GetTransactionsEsploraParams {
  final HttpConfig httpConfig;
  final List<String> addresses;

  const GetTransactionsEsploraParams({
    required this.httpConfig,
    required this.addresses,
  });
}

class GetTransactionsEsploraUseCase
    implements
        UseCaseTE<List<BitcoinTx>, GetTransactionsEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetTransactionsEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, List<BitcoinTx>> call(GetTransactionsEsploraParams params,
      {int maxRetries = 1}) {
    final task = handleNetworkCall(() async {
      return await _bitcoinRepository.getTransactions(
        httpConfig: params.httpConfig,
        addresses: params.addresses,
      );
    }, maxRetries: maxRetries);

    return task.tapError((error) {
      _errorService.captureException(error,
          message: "Failed to get transactions",
          context: {
            "message": error.message,
            "endpoint": error.endpoint,
            "fullUrl": error.fullUrl,
            "statusCode": error.statusCode,
            "addresses": params.addresses,
          });
    }).mapLeft((error) => error.message);
  }
}
