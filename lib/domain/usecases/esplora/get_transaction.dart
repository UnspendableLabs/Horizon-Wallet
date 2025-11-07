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

class GetTransactionEsploraParams {
  final HttpConfig httpConfig;
  final String txid;

  const GetTransactionEsploraParams({
    required this.httpConfig,
    required this.txid,
  });
}

class GetTransactionEsploraUseCase
    implements UseCaseTE<BitcoinTx, GetTransactionEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetTransactionEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, BitcoinTx> call(GetTransactionEsploraParams params) {
    final task = _bitcoinRepository.getTransaction(
      httpConfig: params.httpConfig,
      txid: params.txid,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get transaction",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "txid": params.txid,
              }
            : {
                "message": error?.toString(),
                "txid": params.txid,
              },
      );
    }).mapLeft((error) => error.message);
  }
}

