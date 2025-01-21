import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import "package:equatable/equatable.dart";
import 'package:horizon/domain/services/error_service.dart';

class VirtualSize extends Equatable {
  final int virtualSize;
  final int adjustedVirtualSize;
  const VirtualSize(this.virtualSize, this.adjustedVirtualSize);

  @override
  List<Object?> get props => [virtualSize, adjustedVirtualSize];
}

class ComposeTransactionException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  ComposeTransactionException(this.message, [this.stackTrace]);
}

class ComposeTransactionUseCase {
  final UtxoRepository utxoRepository;
  final BalanceRepository balanceRepository;
  final ErrorService errorService;

  const ComposeTransactionUseCase({
    required this.utxoRepository,
    required this.balanceRepository,
    required this.errorService,
  });

  Future<R> call<P extends ComposeParams, R extends ComposeResponse>({
    required int feeRate,
    required String source,
    required P params,
    required ComposeFunction<P, R> composeFn,
  }) async {
    try {
      // Fetch UTXOs
      final (List<Utxo> inputsSet, List<dynamic>? cachedTxHashes) =
          await utxoRepository.getUnspentForAddress(source,
              excludeCached: true);

      if (inputsSet.isEmpty) {
        final error = Exception('No UTXOs available for transaction');
        errorService.captureException(error,
            message: 'No UTXOs available for transaction',
            context: {
              'source': source,
              'params': params,
              'feeRate': feeRate,
              'composeFn': composeFn,
              'inputsSet': inputsSet,
              'cachedTxHashes': cachedTxHashes,
            });
        throw error;
      }

      List<Utxo> inputsSetForTx = inputsSet;

      if (inputsSet.length > 20) {
        inputsSetForTx = await _getLargeInputsSet(inputsSet);
      }

      final R finalTx = await composeFn(feeRate, inputsSetForTx, params);
      return finalTx;
    } catch (e, stackTrace) {
      throw ComposeTransactionException(e.toString(), stackTrace);
    }
  }

  Future<List<Utxo>> _getLargeInputsSet(List<Utxo> inputsSet) async {
    // if the inputsSet is larger than 20, we need to take 20 UTXOs with the highest values that have no balance
    // 20 is a random number that we know will not cause the load balancer to deny the request
    inputsSet.sort((a, b) => b.value.compareTo(a.value));
    final List<Utxo> inputsForSet = [];

    for (var utxo in inputsSet) {
      if (inputsForSet.length >= 20) {
        break;
      }
      final utxoKey = "${utxo.txid}:${utxo.vout}";
      final balance = await balanceRepository.getBalancesForUTXO(utxoKey);
      if (balance.isEmpty) {
        inputsForSet.add(utxo);
      }
    }

    if (inputsForSet.isEmpty) {
      throw Exception('No UTXOs with no balance found for transaction');
    }

    return inputsForSet;
  }
}
