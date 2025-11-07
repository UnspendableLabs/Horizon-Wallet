import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'dart:math';

class GetVirtualSizeUseCase {
  final TransactionService transactionService;
  final ErrorService errorService;
  const GetVirtualSizeUseCase(
      {required this.transactionService, required this.errorService});

  Future<(int, int)> call<P extends ComposeParams>({
    required ComposeFunction<P, ComposeResponse> composeFunction,
    required P params,
    required List<Utxo> inputsSet,
    required HttpConfig httpConfig,
  }) async {
    // Compose a dummy transaction with minimal fee to estimate size
    final dummyTransactionTask =
        await composeFunction(1, inputsSet, params, httpConfig).run();

    final dummyTransaction = dummyTransactionTask.fold((error) {
      errorService.captureException(error,
          message: 'Failed to compose dummy transaction',
          context: {
            'message': error.message,
            'endpoint': error.endpoint,
            'fullUrl': error.fullUrl,
            'statusCode': error.statusCode,
          });
      throw error;
    }, (dummyTransaction) => dummyTransaction);

    // Calculate the virtual size
    final virtualSize =
        transactionService.getVirtualSize(dummyTransaction.rawtransaction);

    final sigops = transactionService.countSigOps(
      rawtransaction: dummyTransaction.rawtransaction,
    );

    final adjustedVirtualSize = max(virtualSize, sigops * 5);

    return (virtualSize, adjustedVirtualSize);
  }
}
