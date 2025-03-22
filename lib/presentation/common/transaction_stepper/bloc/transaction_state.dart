import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_state.freezed.dart';

/// Base interface that all transaction states must implement
abstract interface class TransactionStateBase {
  /// Get the current loading status
  bool get isLoading;

  /// Get the current error message, if any
  String? get error;
}

/// Base state for loading status and errors
@freezed
class TransactionLoadingState with _$TransactionLoadingState {
  const factory TransactionLoadingState.initial() = _Initial;
  const factory TransactionLoadingState.loading() = _Loading;
  const factory TransactionLoadingState.success() = _Success;
  const factory TransactionLoadingState.error(String message) = _Error;
}
