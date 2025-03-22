import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

part 'transaction_state.freezed.dart';

/// Generic transaction state with type parameter T for success data
@freezed
class TransactionState<T> with _$TransactionState<T> {
  /// Initial state before any data is loaded
  const factory TransactionState.initial() = _Initial<T>;

  /// Loading state while data is being fetched
  const factory TransactionState.loading() = _Loading<T>;

  /// Error state when something went wrong
  const factory TransactionState.error(String message) = _Error<T>;

  /// Success state with generic data of type T
  const factory TransactionState.success({
    required MultiAddressBalance balances,
    T? data,
  }) = _Success<T>;
}
