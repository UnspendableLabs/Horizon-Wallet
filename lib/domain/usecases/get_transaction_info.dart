import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/transaction_info.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/repositories/transaction_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class GetTransactionInfoParams {
  final HttpConfig httpConfig;
  final String raw;

  const GetTransactionInfoParams({
    required this.httpConfig,
    required this.raw,
  });
}

class GetTransactionInfoUseCase
    implements UseCaseTE<TransactionInfo, GetTransactionInfoParams, String> {
  final TransactionRepository _transactionRepository;
  final ErrorService _errorService;

  GetTransactionInfoUseCase({
    TransactionRepository? transactionRepository,
    ErrorService? errorService,
  })  : _transactionRepository =
            transactionRepository ?? GetIt.I<TransactionRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, TransactionInfo> call(GetTransactionInfoParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _transactionRepository.getInfo(
          raw: params.raw,
          httpConfig: params.httpConfig,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get transaction info",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
        },
      );
    }).mapLeft((error) => error.message);
  }
}

class GetTransactionInfoByTxIdParams {
  final HttpConfig httpConfig;
  final String txid;

  const GetTransactionInfoByTxIdParams({
    required this.httpConfig,
    required this.txid,
  });
}

class GetTransactionInfoByTxIdUseCase
    implements
        UseCaseTE<TransactionInfo, GetTransactionInfoByTxIdParams, String> {
  final TransactionRepository _transactionRepository;
  final BitcoinRepository _bitcoinRepository;
  final ErrorService _errorService;

  GetTransactionInfoByTxIdUseCase({
    TransactionRepository? transactionRepository,
    BitcoinRepository? bitcoinRepository,
    ErrorService? errorService,
  })  : _transactionRepository =
            transactionRepository ?? GetIt.I<TransactionRepository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, TransactionInfo> call(
      GetTransactionInfoByTxIdParams params) {
    return handleNetworkCall(() async {
      final txHex = await _bitcoinRepository.getTransactionHex(
          httpConfig: params.httpConfig, txid: params.txid);
      final txInfo = await _transactionRepository.getInfo(
          raw: txHex, httpConfig: params.httpConfig);
      return txInfo;
    }).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get transaction info",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
