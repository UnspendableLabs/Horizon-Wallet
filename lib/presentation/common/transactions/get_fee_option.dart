import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';

num getFeeRate(TransactionState<dynamic, dynamic> state) {
  FeeEstimates feeEstimates = state.formState.getFeeEstimatesOrThrow();
  return switch (state.formState.feeOption) {
    fee_option.Fast() => feeEstimates.fast,
    fee_option.Medium() => feeEstimates.medium,
    fee_option.Slow() => feeEstimates.slow,
    fee_option.Custom(fee: var fee) => fee,
  };
}
