import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import "package:equatable/equatable.dart";
import 'dart:math';

class VirtualSize extends Equatable {
  final int virtualSize;
  final int adjustedVirtualSize;
  const VirtualSize(this.virtualSize, this.adjustedVirtualSize);

  @override
  List<Object?> get props => [virtualSize, adjustedVirtualSize];
}

class ComposeTransactionException implements Exception {
  final String message;
  final StackTrace stackTrace;
  ComposeTransactionException(this.message, this.stackTrace);
}

class ComposeTransactionUseCase {
  final UtxoRepository utxoRepository;
  final BalanceRepository balanceRepository;
  final GetVirtualSizeUseCase getVirtualSizeUseCase;
  final TransactionService transactionService;

  const ComposeTransactionUseCase({
    required this.utxoRepository,
    required this.balanceRepository,
    required this.getVirtualSizeUseCase,
    required this.transactionService,
  });

  Future<(R, VirtualSize)>
      call<P extends ComposeParams, R extends ComposeResponse>({
    required int feeRate,
    required String source,
    required P params,
    required ComposeFunction<P, R> composeFn,
  }) async {
    try {
      List<Utxo> inputsSet = await utxoRepository.getUnspentForAddress(source);

      if (inputsSet.length > 20) {
        inputsSet = await _getLargeInputsSet(inputsSet);
      }

      // Get virtual size
      // (int, int) tuple = await getVirtualSizeUseCase.call(
      //   params: params,
      //   composeFunction: composeFn,
      //   inputsSet: inputsSet,
      // );

      // final int virtualSize = tuple.$1; // virtualSIze
      // final int adjustedVirtualSize = tuple.$2;

      // Calculate total fee
      // final int totalFee = adjustedVirtualSize * feeRate;

      final int feePerKb = feeRate * 1000; // feeRate is in satoshis per vbyte

      // Compose the final transaction with the calculated fee
      final R finalTx = await composeFn(feePerKb, inputsSet, params);

      // Calculate the virtual size
      final virtualSize =
          transactionService.getVirtualSize(finalTx.rawtransaction);

      final sigops = transactionService.countSigOps(
        rawtransaction: finalTx.rawtransaction,
      );

      final adjustedVirtualSize = max(virtualSize, sigops * 5);

      // return (virtualSize, adjustedVirtualSize);

      return (finalTx, VirtualSize(virtualSize, adjustedVirtualSize));
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

    return inputsForSet;
  }
}
