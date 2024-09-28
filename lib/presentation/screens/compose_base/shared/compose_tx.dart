import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:logger/logger.dart';

Future<void> composeTransaction<T, S extends ComposeStateBase, P>({
  required S state,
  required Emitter<S> emit,
  required ComposeTransactionEvent event,
  required UtxoRepository utxoRepository,
  required ComposeRepository composeRepository,
  required TransactionService transactionService,
  required Logger logger,
}) async {
  if (event.params is! P) return;

  final params = event.params as P;
  FeeEstimates? feeEstimates =
      state.feeState.maybeWhen(success: (value) => value, orElse: () => null);

  if (feeEstimates == null) {
    return;
  }

  emit((state as dynamic)
      .copyWith(submitState: const SubmitInitial(loading: true)));

  try {
    final feeRate = switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };

    final utxos =
        await utxoRepository.getUnspentForAddress(event.sourceAddress);
    final inputsSet = utxos.isEmpty ? null : utxos;

    late T composedTransaction;
    late int virtualSize;

    switch (P) {
      case ComposeSendEventParams:
        final sendParams = params as ComposeSendEventParams;
        // Dummy transaction to compute virtual size
        final send = await composeRepository.composeSendVerbose(
          event.sourceAddress,
          sendParams.destinationAddress,
          sendParams.asset,
          sendParams.quantity,
          true,
          1,
          null,
          inputsSet,
        );

        virtualSize = transactionService.getVirtualSize(send.rawtransaction);
        final int totalFee = virtualSize * feeRate;

        composedTransaction = await composeRepository.composeSendVerbose(
          event.sourceAddress,
          sendParams.destinationAddress,
          sendParams.asset,
          sendParams.quantity,
          true,
          totalFee,
          null,
          inputsSet,
        ) as T;
        break;

      case ComposeIssuanceEventParams:
        final issuanceParams = params as ComposeIssuanceEventParams;
        // Dummy transaction to compute virtual size
        final issuance = await composeRepository.composeIssuanceVerbose(
          event.sourceAddress,
          issuanceParams.name,
          issuanceParams.quantity,
          issuanceParams.divisible,
          issuanceParams.lock,
          issuanceParams.reset,
          issuanceParams.description,
          null,
          true,
          1,
          inputsSet,
        );

        virtualSize =
            transactionService.getVirtualSize(issuance.rawtransaction);
        final int totalFee = virtualSize * feeRate;

        composedTransaction = await composeRepository.composeIssuanceVerbose(
          event.sourceAddress,
          issuanceParams.name,
          issuanceParams.quantity,
          issuanceParams.divisible,
          issuanceParams.lock,
          issuanceParams.reset,
          issuanceParams.description,
          null,
          true,
          totalFee,
          inputsSet,
        ) as T;
        break;

      default:
        throw Exception("Unsupported transaction type");
    }

    logger.d('rawTx: ${(composedTransaction as dynamic).rawtransaction}');

    emit((state as dynamic).copyWith(
      submitState: SubmitComposingTransaction<T>(
        composeTransaction: composedTransaction,
        virtualSize: virtualSize,
        fee: virtualSize * feeRate,
        feeRate: feeRate,
      ),
    ) as S);
  } catch (error) {
    emit((state as dynamic).copyWith(
      submitState: SubmitInitial(loading: false, error: error.toString()),
    ) as S);
  }
}
