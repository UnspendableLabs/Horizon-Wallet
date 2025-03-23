import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

part 'transaction_state.freezed.dart';

@freezed
class TransactionState<T> with _$TransactionState<T> {
  const factory TransactionState.initial() = _Initial<T>;
  const factory TransactionState.loading() = _Loading<T>;

  const factory TransactionState.error(String message) = _Error<T>;

  const factory TransactionState.success({
    required SharedTransactionState sharedTransactionState,
    T? data, // Generic data for transactions that may require state beyond the shared transaction state
  }) = _Success<T>;
}

class SharedTransactionState {
  final MultiAddressBalance balances;
  final FeeEstimates feeEstimates;
  final FeeOption? feeOption;

  SharedTransactionState(
      {required this.balances, required this.feeEstimates, this.feeOption});

  SharedTransactionState copyWith({
    MultiAddressBalance? balances,
    FeeEstimates? feeEstimates,
    FeeOption? feeOption,
  }) {
    return SharedTransactionState(
        balances: balances ?? this.balances,
        feeEstimates: feeEstimates ?? this.feeEstimates,
        feeOption: feeOption ?? this.feeOption);
  }
}
