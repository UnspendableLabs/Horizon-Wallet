import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/bitcoin_decoded_tx.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/services/bitcoind_service.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class DecodeRawTransactionParams {
  final HttpConfig httpConfig;
  final String raw;

  const DecodeRawTransactionParams({
    required this.httpConfig,
    required this.raw,
  });
}

class DecodeRawTransactionUseCase
    implements UseCaseTE<DecodedTx, DecodeRawTransactionParams, String> {
  final BitcoindService _bitcoindService;
  final ErrorService _errorService;

  DecodeRawTransactionUseCase({
    BitcoindService? bitcoindService,
    ErrorService? errorService,
  })  : _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, DecodedTx> call(DecodeRawTransactionParams params,
      {int maxRetries = 1}) {
    final task = handleNetworkCall(() async {
      return await _bitcoindService.decoderawtransaction(
        raw: params.raw,
        httpConfig: params.httpConfig,
      );
    }, maxRetries: maxRetries);

    return task.tapError((error) {
      _errorService.captureException(error,
          message: "Failed to decode raw transaction",
          context: {
            "message": error.message,
            "endpoint": error.endpoint,
            "fullUrl": error.fullUrl,
            "statusCode": error.statusCode,
          });
    }).mapLeft((error) => error.message);
  }
}
