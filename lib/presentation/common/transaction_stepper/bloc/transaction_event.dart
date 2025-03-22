/// Base class for all transaction events
abstract class TransactionEvent {}

/// Event triggered when the transaction screen is loaded
/// to request dependencies like fee estimates, balances, etc.
class DependenciesRequested extends TransactionEvent {
  final String assetName;
  final List<String> addresses;

  DependenciesRequested({required this.assetName, required this.addresses});
}

/// Event triggered when moving from input step to confirmation step
class TransactionComposed<T> extends TransactionEvent {}

/// Event triggered when moving from confirmation step to submission step
class TransactionSubmitted<T> extends TransactionEvent {}
