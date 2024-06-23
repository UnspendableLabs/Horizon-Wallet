abstract class ComposeSendState {}

class ComposeSendInitial extends ComposeSendState {}

class ComposeSendLoading extends ComposeSendState {}

class ComposeSendSuccess extends ComposeSendState {
  final String transactionHex;
  final String sourceAddress;

  ComposeSendSuccess({required this.transactionHex, required this.sourceAddress});
}

class ComposeSendError extends ComposeSendState {
  final String message;
  final String? stackTrace;

  ComposeSendError({required this.message, this.stackTrace});
}

class ComposeSendSignSuccess extends ComposeSendState {
  final String signedTransaction;

  ComposeSendSignSuccess({required this.signedTransaction});
}
