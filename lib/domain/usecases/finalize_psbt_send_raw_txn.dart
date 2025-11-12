import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/services/bitcoind_service.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/domain/services/transaction_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class FinalizePsbtSendRawTxnParams {
  final HttpConfig httpConfig;
  final String psbtHex;

  const FinalizePsbtSendRawTxnParams({
    required this.httpConfig,
    required this.psbtHex,
  });
}

class FinalizePsbtSendRawTxnUseCase
    implements UseCaseTE<String, FinalizePsbtSendRawTxnParams, String> {
  final TransactionService _transactionService;
  final BitcoindService _bitcoindService;
  final ErrorService _errorService;

  FinalizePsbtSendRawTxnUseCase({
    TransactionService? transactionService,
    BitcoindService? bitcoindService,
    ErrorService? errorService,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, String> call(FinalizePsbtSendRawTxnParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(() async {
      final finalizedTx = _transactionService.finalizePsbtAndExtractTransaction(
          psbtHex: params.psbtHex);
      final hash = await _bitcoindService.sendrawtransaction(
          finalizedTx, params.httpConfig);
      return hash;
    }, maxRetries: maxRetries)
        .tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to finalize PSBT and send raw transaction",
        context: {
          "debugMessage": error.toDebugString(),
          "url": error.fullUrl,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
