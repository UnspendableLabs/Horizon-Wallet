import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

abstract class ComposeCancelEvent extends ComposeBaseEvent {}

class ComposeResponseReceived extends ComposeCancelEvent {
  final ComposeCancelResponse response;
  final VirtualSize virtualSize;
  final num feeRate;

  ComposeResponseReceived({
    required this.response,
    required this.virtualSize,
    required this.feeRate,
  });
}

class ConfirmationBackButtonPressed extends ComposeCancelEvent {}
