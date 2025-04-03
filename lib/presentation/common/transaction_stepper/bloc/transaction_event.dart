import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/fee_option.dart';

abstract class TransactionEvent {}

class DependenciesRequested extends TransactionEvent {}

class FeeOptionSelected extends TransactionEvent {
  final FeeOption feeOption;

  FeeOptionSelected({required this.feeOption});
}

class TransactionComposed<T> extends TransactionEvent {
  final String sourceAddress;
  final T params;

  TransactionComposed({
    required this.sourceAddress,
    required this.params,
  });
}

class TransactionBroadcasted extends TransactionEvent {
  final DecryptionStrategy decryptionStrategy;

  TransactionBroadcasted({required this.decryptionStrategy});
}
