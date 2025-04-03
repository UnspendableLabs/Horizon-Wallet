import 'package:horizon/domain/entities/fee_option.dart';

abstract class TransactionEvent {}

class DependenciesRequested extends TransactionEvent {
  final String assetName;
  final List<String> addresses;

  DependenciesRequested({required this.assetName, required this.addresses});
}

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

class TransactionBroadcasted<T> extends TransactionEvent {
  final dynamic decryptionStrategy;

  TransactionBroadcasted({required this.decryptionStrategy});
}
