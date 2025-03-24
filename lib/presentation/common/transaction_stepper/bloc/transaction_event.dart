import 'package:horizon/domain/entities/fee_option.dart';

/// Base class for all transaction events
abstract class TransactionEvent {}

/// Event triggered when the transaction screen is loaded
/// to request dependencies like fee estimates, balances, etc.
class DependenciesRequested extends TransactionEvent {
  final String assetName;
  final List<String> addresses;

  DependenciesRequested({required this.assetName, required this.addresses});
}

/// Event triggered when a fee option is selected
class FeeOptionSelected extends TransactionEvent {
  final FeeOption feeOption;

  FeeOptionSelected({required this.feeOption});
}

/// Event triggered when moving from input step to confirmation step
class TransactionComposed<T> extends TransactionEvent {
  final String sourceAddress;
  final T params;

  TransactionComposed({
    required this.sourceAddress,
    required this.params,
  });

  /// Helper method for subclasses to validate parameters
  bool validate() {
    // Base validation that applies to all transactions
    if (sourceAddress.isEmpty) {
      return false;
    }

    // Specific validation is handled by subclasses
    return true;
  }
}

/// Event triggered when moving from confirmation step to submission step
class TransactionSubmitted<T> extends TransactionEvent {}
