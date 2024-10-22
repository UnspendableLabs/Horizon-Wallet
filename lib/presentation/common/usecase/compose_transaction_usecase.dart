import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_fn.dart';

class VirtualSize {
  final int virtualSize;
  final int adjustedVirtualSize;
  VirtualSize(this.virtualSize, this.adjustedVirtualSize);
}

class ComposeTransactionException implements Exception {
  final String message;
  final StackTrace stackTrace;
  ComposeTransactionException(this.message, this.stackTrace);
}

class ComposeTransactionUseCase {
  final UtxoRepository utxoRepository;
  final GetVirtualSizeUseCase getVirtualSizeUseCase;

  const ComposeTransactionUseCase({
    required this.utxoRepository,
    required this.getVirtualSizeUseCase,
  });

  Future<(R, VirtualSize)> call<P extends ComposeParams, R extends ComposeResponse>({
    required int feeRate,
    required String source,
    required P params,
    required ComposeFunction<P, R> composeFn,
  }) async {
    try {
      final List<Utxo> inputsSet =
          await utxoRepository.getUnspentForAddress(source);

      // Get virtual size
      (int, int) tuple = await getVirtualSizeUseCase.call(
        params: params,
        composeFunction: composeFn,
        inputsSet: inputsSet,
      );

      final int virtualSize = tuple.$1; // virtualSIze
      final int adjustedVirtualSize = tuple.$2;

      // Calculate total fee
      final int totalFee = adjustedVirtualSize * feeRate;

      // Compose the final transaction with the calculated fee
      final R finalTx = await composeFn(totalFee, inputsSet, params);

      return (finalTx, VirtualSize(virtualSize, adjustedVirtualSize));
    } catch (e, stackTrace) {
      throw ComposeTransactionException(e.toString(), stackTrace);
    }
  }
}
