import "package:horizon/api/v2_api.dart" as v2_api;

abstract class ComposeSendState {}

class ComposeSendInitial extends ComposeSendState {}

class ComposeSendLoading extends ComposeSendState {}

class ComposeSendSuccess extends ComposeSendState {
  final String transactionHex;
  final v2_api.Info info;
  final String sourceAddress;

  ComposeSendSuccess({required this.transactionHex, required this.info, required this.sourceAddress});
}

class ComposeSendError extends ComposeSendState {
  final String message;

  ComposeSendError({required this.message});
}

class ComposeSendSignSuccess extends ComposeSendState {
  final String signedTransaction;

  ComposeSendSignSuccess({required this.signedTransaction});
}
