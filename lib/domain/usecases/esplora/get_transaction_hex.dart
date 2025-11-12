import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "../usecase.dart";
export "../usecase.dart";

class GetTransactionHexEsploraParams {
  final HttpConfig httpConfig;
  final String txid;

  const GetTransactionHexEsploraParams({
    required this.httpConfig,
    required this.txid,
  });
}

class GetTransactionHexEsploraUseCase
    implements UseCaseTE<String, GetTransactionHexEsploraParams, String> {
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetTransactionHexEsploraUseCase({
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, String> call(GetTransactionHexEsploraParams params) {
    final task = handleNetworkCall(() async {
      return await _bitcoinRepository.getTransactionHex(
        httpConfig: params.httpConfig,
        txid: params.txid,
      );
    });

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get transaction hex",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "txid": params.txid,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
