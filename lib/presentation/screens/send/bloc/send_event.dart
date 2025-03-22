import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

/// Send-specific implementation of DependenciesRequested
class SendDependenciesRequested extends DependenciesRequested {
  // No arguments needed
}

/// Send-specific implementation of TransactionComposed
class SendTransactionComposed extends TransactionComposed {
  // No arguments needed
}

/// Send-specific implementation of TransactionSubmitted
class SendTransactionSubmitted extends TransactionSubmitted {
  // No arguments needed
}

/// Event for when the user enters a password to sign the transaction
class SendTransactionSigned extends TransactionEvent {
  // No arguments needed
}
