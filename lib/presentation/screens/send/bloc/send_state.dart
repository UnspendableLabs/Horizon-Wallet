import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';

part 'send_state.freezed.dart';

/// Send page state wrapping a TransactionState with potential send-specific fields
@freezed
class SendState with _$SendState {
  const factory SendState({
    required TransactionState transactionState,
    // Add send-specific properties here
    String? destinationAddress,
    String? amount,
  }) = _SendState;

  const SendState._();

  /// Initial state constructor
  factory SendState.initial() => const SendState(
        transactionState: TransactionState.initial(),
      );

  /// Loading state constructor
  factory SendState.loading() => const SendState(
        transactionState: TransactionState.loading(),
      );

  /// Error state constructor
  factory SendState.error(String message) => SendState(
        transactionState: TransactionState.error(message),
      );

  /// Success state constructor
  factory SendState.success(List<MultiAddressBalance> balances) => SendState(
        transactionState: TransactionState.success(balances: balances),
      );
}

/// MaxValueState represents the state for calculating maximum transferable value.
// @freezed
// class MaxValueState with _$MaxValueState {
//   const factory MaxValueState.initial() = _MaxValueInitial;
//   const factory MaxValueState.loading() = _MaxValueLoading;
//   const factory MaxValueState.success(int maxValue) = _MaxValueSuccess;
//   const factory MaxValueState.error(String error) = _MaxValueError;
// }
