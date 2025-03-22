import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';

/// State for the send transaction flow - super minimal
class SendState implements TransactionStateBase {
  @override
  final bool isLoading;

  @override
  final String? error;

  const SendState({
    this.isLoading = false,
    this.error,
  });

  SendState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SendState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
