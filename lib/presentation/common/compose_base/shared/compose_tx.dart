import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:logger/logger.dart';

Future<void> composeTransaction<T, S extends ComposeStateBase>({
  required S state,
  required Emitter<S> emit,
  required ComposeTransactionEvent event,
  required UtxoRepository utxoRepository,
  required ComposeRepository composeRepository,
  required TransactionService transactionService,
  required Logger logger,
  required Function(List<Utxo>, int feeRate) transactionHandler,
}) async {
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

    (composedTransaction, virtualSize) =
        await transactionHandler(inputsSet ?? [], feeRate);

    logger.d('rawTx: ${(composedTransaction as dynamic).rawtransaction}');

    emit((state as dynamic).copyWith(
      submitState: SubmitComposingTransaction<T>(
        composeTransaction: composedTransaction,
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
