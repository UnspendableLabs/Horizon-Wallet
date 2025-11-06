import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/services/bitcoind_service.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class SendRawTransactionParams {
  final HttpConfig httpConfig;
  final String signedHex;

  const SendRawTransactionParams({
    required this.httpConfig,
    required this.signedHex,
  });
}

class SendRawTransactionUseCase
    implements UseCaseTE<String, SendRawTransactionParams, String> {
  final BitcoindService _bitcoindService;
  final ErrorService _errorService;

  SendRawTransactionUseCase({
    BitcoindService? bitcoindService,
    ErrorService? errorService,
  })  : _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, String> call(SendRawTransactionParams params) {
    final task = _bitcoindService.sendrawtransaction(
      params.signedHex,
      params.httpConfig,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to send raw transaction",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
              }
            : {
                "message": error?.toString(),
              },
      );
    }).mapLeft((error) => error.message);
  }
}
