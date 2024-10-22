import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'dart:math';

class GetVirtualSizeUseCase {
  final TransactionService transactionService;

  const GetVirtualSizeUseCase({required this.transactionService});

  Future<(int, int)> call<P extends ComposeParams>({
    required ComposeFunction<P, ComposeResponse> composeFunction,
    required P params,
    required List<Utxo> inputsSet,
  }) async {
    // Compose a dummy transaction with minimal fee to estimate size
    final dummyTransaction = await composeFunction(1, inputsSet, params);

    // Calculate the virtual size
    final virtualSize =
        transactionService.getVirtualSize(dummyTransaction.rawtransaction);

    final sigops = transactionService.countSigOps(
      rawtransaction: dummyTransaction.rawtransaction,
    );

    final adjustedVirtualSize = max(virtualSize, sigops * 5);

    print("sigops $sigops");
    print("sigops * 5  ${sigops * 5 }");


    return (virtualSize, adjustedVirtualSize);
  }
}
