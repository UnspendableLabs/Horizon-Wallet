import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

abstract class ComposeOrderEvent extends ComposeBaseEvent {}

class ComposeResponseReceived extends ComposeOrderEvent {
  final ComposeOrderResponse response;
  final VirtualSize virtualSize;
  final int feeRate;

  ComposeResponseReceived({
    required this.response,
    required this.virtualSize,
    required this.feeRate,
  });
}

class ConfirmationBackButtonPressed extends ComposeOrderEvent {}
