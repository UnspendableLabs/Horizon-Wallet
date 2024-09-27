import 'package:flutter/foundation.dart';

/// Abstract class for submit state, allows for different implementations.
@immutable
abstract class SubmitState {
  const SubmitState();
}

/// Initial state before submission begins.
class SubmitInitial extends SubmitState {
  final bool loading;
  final String? error;

  const SubmitInitial({this.loading = false, this.error});
}

/// State when submission is in progress.
class SubmitComposing extends SubmitState {
  const SubmitComposing();
}

/// State when submission is successful.
class SubmitSuccess extends SubmitState {
  final String transactionHex;
  final String sourceAddress;

  const SubmitSuccess({
    required this.transactionHex,
    required this.sourceAddress,
  });
}

/// State when submission fails.
class SubmitError extends SubmitState {
  final String error;

  const SubmitError(this.error);
}
